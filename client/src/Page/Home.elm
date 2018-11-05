module Page.Home exposing (init, view, update, Msg, Model)

import Api
import Browser
import Html exposing (button, div, form, h4, input, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Source exposing (Source, SourceName(..), SourceType)
import Task
import Url


type FeedCreationState
    = None
    | Waiting
    | Error
    | Created Api.Feed


type alias Model =
    { session : Api.Session
    , subscriptions : List Api.Subscription
    , urlInput : String
    , feedCreationState : FeedCreationState
    }



-- Init


init : Api.Session -> ( Model, Cmd Msg )
init session =
    let
        model =
            { session = session
            , subscriptions = []
            , urlInput = ""
            , feedCreationState = None
            }

        cmd =
            Api.getCurrentSubscriptionsRequest session
                |> Http.send SubscriptionsLoaded
    in
        ( model, cmd )



-- Update


createFeedTask session source =
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
        Api.createOrGetFeedTask session
            { name = name
            , type_ = type_
            , id = source.sourceId
            }


type Msg
    = SubscriptionsLoaded (Result Http.Error (List Api.Subscription))
    | UrlInputChanged String
    | CreateFeed
    | FeedCreated (Result Http.Error Api.Feed)
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

        CreateFeed ->
            let
                cmd =
                    case sourceFromUrlInput model.urlInput of
                        Just source ->
                            createFeedTask model.session source
                                |> Task.attempt FeedCreated

                        Nothing ->
                            Cmd.none
            in
                ( { model | urlInput = "", feedCreationState = Waiting }, cmd )

        FeedCreated (Ok feed) ->
            ( { model | feedCreationState = Created feed }, Cmd.none )

        FeedCreated (Err error) ->
            ( { model | feedCreationState = Error }, Cmd.none )

        CreateSubscription ->
            let
                cmd =
                    case model.feedCreationState of
                        None ->
                            Cmd.none

                        Waiting ->
                            Cmd.none

                        Error ->
                            Cmd.none

                        Created feed ->
                            Api.createSubscriptionRequest model.session feed.id
                                |> Http.send SubscriptionCreated
            in
                ( model, cmd )

        SubscriptionCreated (Ok subscription) ->
            let
                subscriptions =
                    subscription :: model.subscriptions
            in
                ( { model | subscriptions = subscriptions, feedCreationState = None }, Cmd.none )

        SubscriptionCreated (Err _) ->
            ( { model | feedCreationState = None }, Cmd.none )



-- View


feedPreview feed =
    let
        title =
            Maybe.withDefault "None" feed.title

        description =
            Maybe.withDefault "None" feed.description
    in
        div []
            [ h4 [] [ text "ID" ]
            , text feed.id
            , h4 [] [ text "Title" ]
            , text title
            , h4 [] [ text "Description" ]
            , text description
            , form
                [ onSubmit CreateSubscription ]
                [ button [ type_ "submit" ] [ text "Subscribe" ]
                ]
            ]


view : Model -> Browser.Document Msg
view model =
    let
        feedCreationStatusInfo =
            case model.feedCreationState of
                None ->
                    text ""

                Waiting ->
                    text "Feed is being created"

                Error ->
                    text "Failed to create feed"

                Created feed ->
                    feedPreview feed
    in
        { title = "Home"
        , body =
            [ div [] [ text "You're HOME!" ]
            , form [ onSubmit CreateFeed ]
                [ input [ type_ "text", value model.urlInput, onInput UrlInputChanged ] []
                , button [ type_ "submit" ] [ text "Add URL" ]
                ]
            , feedCreationStatusInfo
            ]
        }
