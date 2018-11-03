module Api
    exposing
        ( createUserRequest
        , createSessionRequest
        , getCurrentSubscriptionsRequest
        , createSubscriptionRequest
        , User
        , Session
        , Subscription
        )

import Http
import Json.Decode as Decode exposing (at, field, list, nullable, string)
import Json.Encode as Encode


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


type alias CreateSubscriptionParams =
    { name : String
    , type_ : String
    , id : String
    }


createSubscriptionRequest : Session -> CreateSubscriptionParams -> Http.Request Subscription
createSubscriptionRequest session params =
    let
        url =
            baseUri ++ "/api/subscriptions"

        body =
            Encode.object
                [ ( "source", Encode.string params.name )
                , ( "source_type", Encode.string params.type_ )
                , ( "source_id", Encode.string params.id )
                ]

        decoder =
            (field "data" subscriptionDecoder)
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
