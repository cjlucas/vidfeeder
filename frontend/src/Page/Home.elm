module Page.Home exposing (init, view, update, Msg, Model)

import Api
import Browser
import Html exposing (a, button, div, form, h1, h2, h3, h4, i, img, input, p, span, text)
import Html.Attributes
    exposing
        ( attribute
        , class
        , disabled
        , height
        , href
        , id
        , placeholder
        , src
        , style
        , target
        , type_
        , value
        , width
        )
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
    { session : Maybe Api.Session
    , subscriptions : List Api.Subscription
    , urlInput : String
    , feedCreationState : FeedCreationState
    }



-- Init


init : Maybe Api.Session -> ( Model, Cmd Msg )
init maybeSession =
    let
        model =
            { session = maybeSession
            , subscriptions = []
            , urlInput = ""
            , feedCreationState = None
            }

        cmd =
            case maybeSession of
                Just session ->
                    Api.getCurrentSubscriptionsRequest session
                        |> Http.send SubscriptionsLoaded

                Nothing ->
                    Cmd.none
    in
        ( model, cmd )



-- Update


createFeedTask source =
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
        Api.createOrGetFeedTask
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
                            createFeedTask source
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
                            case model.session of
                                Just session ->
                                    Api.createSubscriptionRequest session feed.id
                                        |> Http.send SubscriptionCreated

                                Nothing ->
                                    Cmd.none
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


classes list =
    class (String.join " " list)


inputUrlValid inputUrl =
    let
        url =
            String.trim inputUrl
    in
        sourceFromUrlInput url /= Nothing


feedUrlForm inputText =
    let
        inputBorder =
            if inputUrlValid inputText || (String.length << String.trim) inputText == 0 then
                "border-grey-light"
            else
                "border-red"

        buttonDisabledClasses =
            if inputUrlValid inputText then
                [ "hover:bg-blue-dark" ]
            else
                [ "opacity-50", "cursor-not-allowed" ]

        buttonClasses =
            [ "border-4"
            , "px-2"
            , "py-1"
            , "border-transparent"
            , "text-white"
            , "font-bold"
            , "bg-blue"
            , "rounded-lg"
            ]
                ++ buttonDisabledClasses
    in
        form
            [ class ("flex items-center py-2 border-b border-b2 " ++ inputBorder)
            , onSubmit CreateFeed
            ]
            [ input
                [ class "pr-4 appearance-none bg-transparent border-none w-full text-grey-dark focus:outline-none"
                , value inputText
                , type_ "text"
                , placeholder "Feed URL"
                , onInput UrlInputChanged
                ]
                []
            , button
                [ classes buttonClasses
                , disabled (not (inputUrlValid inputText))
                ]
                [ text "Create" ]
            ]


feedPreview feed =
    let
        title =
            Maybe.withDefault "None" feed.title

        description =
            Maybe.withDefault "No description available." feed.description

        image =
            case feed.imageUrl of
                Just url ->
                    img [ class "h-32 w-32", src url ] []

                Nothing ->
                    text ""
    in
        div []
            [ div [ class "flex mb-4" ]
                [ image
                , div [ class "pl-6" ]
                    [ h1 [ class "mb-2" ] [ text title ]
                    , text description
                    ]
                ]
            , div [ class "flex justify-between items-center pt-2 pb-2" ]
                [ a
                    [ class "block flex items-center no-underline text-grey-light hover:text-orange"
                    , href ("http://localhost:5000/rss/" ++ feed.id)
                    , target "_blank"
                    ]
                    [ i [ class "fa fa-2x fa-rss pr-2" ] []
                    , span [ class "font-bold text-2xl" ] [ text "RSS" ]
                    ]
                , img [ class "h-8", src "http://oi63.tinypic.com/34njn82.jpg" ] []
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
                    div [ class "text-center" ]
                        [ p [ class "font-bold text-2xl" ] [ text "We're working on it!" ]
                        , div [ class "sk-double-bounce" ]
                            [ div [ class "sk-child sk-double-bounce1" ] []
                            , div [ class "sk-child sk-double-bounce2" ] []
                            ]
                        , p [] [ text "Please be patient while we generate your feed." ]
                        ]

                Error ->
                    div [ class "text-center" ]
                        [ p [ class "font-bold text-2xl" ] [ text "Ut oh!" ]
                        , i [ class "fa fa-5x fa-exclamation-circle my-4 text-red" ] []
                        , p [] [ text "This feed is taking longer to generate than expected, please try again." ]
                        ]

                Created feed ->
                    feedPreview feed
    in
        { title = "Home"
        , body =
            [ div [ class "flex container mx-auto my-auto h-screen font-sans" ]
                [ div [ class "mx-auto my-auto w-1/2" ]
                    [ div [ class "rounded-xl shadow-lg px-6 pt-12 pb-4 bg-white" ]
                        [ feedUrlForm model.urlInput
                        , div [ class "mt-8" ]
                            [ feedCreationStatusInfo
                            ]
                        ]
                    ]
                ]
            ]
        }
