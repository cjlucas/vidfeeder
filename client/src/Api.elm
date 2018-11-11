module Api
    exposing
        ( createUserRequest
        , createSessionRequest
        , getCurrentSubscriptionsRequest
        , createSubscriptionRequest
        , createOrGetFeedTask
        , Feed
        , User
        , Session
        , Subscription
        )

import Dict
import Http
import Json.Decode as Decode exposing (at, decodeString, field, list, nullable, string)
import Json.Encode as Encode
import Url
import Url.Parser exposing ((</>), s)
import Task exposing (Task)


type alias User =
    { id : String
    , email : String
    }


userDecoder =
    Decode.map2 User
        (at [ "data", "user", "id" ] string)
        (at [ "data", "user", "email" ] string)


type alias Session =
    { userId : String
    , accessToken : String
    }


sessionDecoder =
    Decode.map2 Session
        (at [ "session", "user_id" ] string)
        (at [ "session", "access_token" ] string)


type alias Subscription =
    { id : String
    , title : Maybe String
    }


subscriptionDecoder =
    Decode.map2 Subscription
        (at [ "subscription", "id" ] string)
        (at [ "subscription", "title" ] (nullable string))


type alias Feed =
    { id : String
    , title : Maybe String
    , description : Maybe String
    , imageUrl : Maybe String
    }


feedDecoder =
    Decode.map4 Feed
        (at [ "feed", "id" ] string)
        (at [ "feed", "title" ] (nullable string))
        (at [ "feed", "description" ] (nullable string))
        (at [ "feed", "image_url" ] (nullable string))


baseUri =
    "http://localhost:5000"


createUserRequest : String -> String -> String -> Http.Request User
createUserRequest email password passwordConfirmation =
    let
        url =
            baseUri ++ "/api/users"

        body =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                , ( "password_confirmation", Encode.string passwordConfirmation )
                ]
    in
        Http.post url (Http.jsonBody body) userDecoder


createSessionRequest : String -> String -> Http.Request Session
createSessionRequest email password =
    let
        url =
            baseUri ++ "/api/sessions"

        body =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]
    in
        Http.post url (Http.jsonBody body) sessionDecoder


getCurrentSubscriptionsRequest : Session -> Http.Request (List Subscription)
getCurrentSubscriptionsRequest session =
    let
        url =
            baseUri ++ "/api/users/" ++ session.userId ++ "/subscriptions"

        decoder =
            (field "data" (list subscriptionDecoder))
    in
        Http.request
            { method = "GET"
            , headers =
                [ Http.header "Authorization" ("Bearer " ++ session.accessToken)
                ]
            , url = url
            , body = Http.emptyBody
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


createSubscriptionRequest : Session -> String -> Http.Request Subscription
createSubscriptionRequest session feedId =
    let
        url =
            baseUri ++ "/api/subscriptions"

        body =
            Encode.object
                [ ( "feed_id", Encode.string feedId )
                ]

        decoder =
            field "data" subscriptionDecoder
    in
        Http.request
            { method = "POST"
            , headers =
                [ Http.header "Authorization" ("Bearer " ++ session.accessToken)
                ]
            , url = url
            , body = Http.jsonBody body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


type alias CreateFeedParams =
    { name : String
    , type_ : String
    , id : String
    }


createFeedRequest : Session -> CreateFeedParams -> Http.Request Feed
createFeedRequest session params =
    let
        url =
            baseUri ++ "/api/feeds"

        body =
            Encode.object
                [ ( "source", Encode.string params.name )
                , ( "source_type", Encode.string params.type_ )
                , ( "source_id", Encode.string params.id )
                ]

        decoder =
            (field "data" feedDecoder)
    in
        Http.request
            { method = "POST"
            , headers =
                [ Http.header "Authorization" ("Bearer " ++ session.accessToken)
                ]
            , url = url
            , body = Http.jsonBody body
            , expect = Http.expectJson decoder
            , timeout = Nothing
            , withCredentials = False
            }


getFeedRequest : String -> Http.Request Feed
getFeedRequest id =
    let
        url =
            baseUri ++ "/api/feeds/" ++ id

        decoder =
            (field "data" feedDecoder)
    in
        Http.get url decoder


type CreateFeedResponse
    = FeedCreated String
    | FeedExists Feed


createOrGetFeedTask : CreateFeedParams -> Task Http.Error Feed
createOrGetFeedTask params =
    let
        body =
            Encode.object
                [ ( "source", Encode.string params.name )
                , ( "source_type", Encode.string params.type_ )
                , ( "source_id", Encode.string params.id )
                ]

        decoder =
            field "data" feedDecoder

        handleResponse response =
            case response.status.code of
                {--Http client will auto redirect on 303--}
                200 ->
                    case decodeString decoder response.body of
                        Ok feed ->
                            Ok (FeedExists feed)

                        Err _ ->
                            Err "failed to decode body"

                201 ->
                    let
                        maybeFeedId =
                            response.headers
                                |> Debug.log "headers"
                                |> Dict.get "location"
                                |> Maybe.andThen Url.fromString
                                |> Maybe.andThen (Url.Parser.parse (s "api" </> s "feeds" </> Url.Parser.string))
                    in
                        case maybeFeedId of
                            Just feedId ->
                                Ok (FeedCreated feedId)

                            Nothing ->
                                Err "could not parse location header"

                code ->
                    Err ("unkown code: " ++ (String.fromInt code))

        createFeedTask =
            Http.request
                { method = "POST"
                , headers = []
                , url = baseUri ++ "/api/feeds"
                , body = Http.jsonBody body
                , expect = Http.expectStringResponse handleResponse
                , timeout = Nothing
                , withCredentials = False
                }
                |> Http.toTask
    in
        createFeedTask
            |> Task.andThen
                (\feedResponse ->
                    case feedResponse of
                        FeedCreated id ->
                            getFeedRequest id |> Http.toTask

                        FeedExists feed ->
                            Task.succeed feed
                )
