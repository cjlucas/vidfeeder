module Page.Home exposing (init, view, update, Msg, Model)

import Api
import Browser
import Html exposing (button, div, form, input, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Source exposing (Source, SourceName(..), SourceType)
import Url


type alias Model =
    { session : Api.Session
    , subscriptions : List Api.Subscription
    , urlInput : String
    }



-- Init


init : Api.Session -> ( Model, Cmd Msg )
init session =
    let
        model =
            { session = session
            , subscriptions = []
            , urlInput = ""
            }

        cmd =
            Api.getCurrentSubscriptionsRequest session
                |> Http.send SubscriptionsLoaded
    in
        ( model, cmd )



-- Update


createSubscriptionRequest session source =
    let
        name =
            case source.sourceName of
                YouTube ->
                    "youtube"

        type_ =
            case source.sourceType of
                Source.User ->
                    "user"

                Source.Channel ->
                    "channel"

                Source.Playlist ->
                    "playlist"
    in
        Api.createSubscriptionRequest session
            { name = name
            , type_ = type_
            , id = source.sourceId
            }


type Msg
    = SubscriptionsLoaded (Result Http.Error (List Api.Subscription))
    | UrlInputChanged String
    | CreateSubscription
    | SubscriptionCreated (Result Http.Error Api.Subscription)


sourceFromUrlInput input =
    case Url.fromString input of
        Just url ->
            Source.fromUrl url

        Nothing ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubscriptionsLoaded (Ok subscriptions) ->
            ( { model | subscriptions = subscriptions }, Cmd.none )

        SubscriptionsLoaded (Err error) ->
            ( model, Cmd.none )

        UrlInputChanged input ->
            ( { model | urlInput = input }, Cmd.none )

        CreateSubscription ->
            let
                cmd =
                    case sourceFromUrlInput model.urlInput of
                        Just source ->
                            Http.send SubscriptionCreated <|
                                createSubscriptionRequest model.session source

                        Nothing ->
                            Cmd.none
            in
                ( { model | urlInput = "" }, cmd )

        SubscriptionCreated (Ok subscription) ->
            let
                subscriptions =
                    subscription :: model.subscriptions
            in
                ( { model | subscriptions = subscriptions }, Cmd.none )

        SubscriptionCreated (Err error) ->
            ( model, Cmd.none )



-- View


view : Model -> Browser.Document Msg
view model =
    { title = "Home"
    , body =
        [ div [] [ text "You're HOME!" ]
        , form [ onSubmit CreateSubscription ]
            [ input [ type_ "text", onInput UrlInputChanged ] []
            , button [ type_ "submit", value model.urlInput ] [ text "Add URL" ]
            ]
        ]
    }
