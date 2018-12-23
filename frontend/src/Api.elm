module Api exposing
    ( Feed
    , GetFeedResponse(..)
    , Session
    , Subscription
    , User
    , createEmailNotification
    , createOrGetFeedTask
    , createSessionRequest
    , createSubscriptionRequest
    , createUserRequest
    , getCurrentSubscriptionsRequest
    )

import Dict
import Http
import Json.Decode as Decode exposing (at, decodeString, field, list, nullable, string)
import Json.Encode as Encode
import Task exposing (Task)
import Url
import Url.Parser exposing ((</>), s)


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


type alias ImportingFeed =
    { id : String }


importingFeedDecoder =
    Decode.map ImportingFeed
        (at [ "feed", "id" ] string)


baseUri =
    "{{API_BASE_URI}}"


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
            field "data" (list subscriptionDecoder)
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


type GetFeedResponse
    = GotFeed Feed
    | FeedNotReady String


getFeedRequest : String -> Http.Request (Maybe Feed)
getFeedRequest id =
    let
        url =
            baseUri ++ "/api/feeds/" ++ id

        decoder =
            field "data" feedDecoder

        handleResponse response =
            case Debug.log "omghere" response.status.code of
                200 ->
                    case decodeString decoder response.body of
                        Ok feed ->
                            Ok (Just feed)

                        Err _ ->
                            Err "failed to decode body"

                202 ->
                    Ok Nothing

                code ->
                    Err ("Unknown code: " ++ String.fromInt code)
    in
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectStringResponse handleResponse
        , timeout = Nothing
        , withCredentials = False
        }


type CreateFeedResponse
    = FeedCreated String
    | FeedExists Feed


type alias CreateFeedParams =
    { name : String
    , type_ : String
    , id : String
    }


createOrGetFeedTask : CreateFeedParams -> Task Http.Error GetFeedResponse
createOrGetFeedTask params =
    let
        body =
            Encode.object
                [ ( "source", Encode.string params.name )
                , ( "source_type", Encode.string params.type_ )
                , ( "source_id", Encode.string params.id )
                ]

        dataDecoder decoder =
            field "data" decoder

        handleResponse response =
            case response.status.code of
                {--Http client will auto redirect on 303--}
                200 ->
                    case decodeString (dataDecoder feedDecoder) response.body of
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

                202 ->
                    case decodeString (dataDecoder importingFeedDecoder) response.body of
                        Ok importingFeed ->
                            Ok (FeedCreated importingFeed.id)

                        Err _ ->
                            Err "failed to decode body"

                code ->
                    Err ("Unknown code: " ++ String.fromInt code)

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
                        getFeedRequest id
                            |> Http.toTask
                            |> Task.andThen
                                (\maybeFeed ->
                                    case maybeFeed of
                                        Just feed ->
                                            Task.succeed (GotFeed feed)

                                        Nothing ->
                                            Task.succeed (FeedNotReady id)
                                )

                    FeedExists feed ->
                        Task.succeed (GotFeed feed)
            )


type alias CreateEmailNotificationParams =
    { email : String
    , feedId : String
    }


createEmailNotification : CreateEmailNotificationParams -> Http.Request ()
createEmailNotification params =
    let
        url =
            baseUri ++ "/api/email_notifications"

        body =
            Encode.object
                [ ( "email", Encode.string params.email )
                , ( "feed_id", Encode.string params.feedId )
                ]

        handleResponse response =
            case response.status.code of
                200 ->
                    Ok ()

                code ->
                    Err ("Unknown code" ++ String.fromInt code)
    in
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = Http.jsonBody body
        , expect = Http.expectStringResponse handleResponse
        , timeout = Nothing
        , withCredentials = False
        }
