module Page.Home exposing (Model, Msg, init, update, view)

import Api
import Browser
import Html exposing (Html, a, button, div, form, h1, h2, h3, h4, i, img, input, p, span, text)
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


type RequestState response
    = Waiting
    | Error
    | Done response


type ViewState
    = AwaitingFeedUrlInput
    | FeedRequestMade (RequestState Api.GetFeedResponse)
    | EmailNotificationRequestMade (RequestState ())


type alias Model =
    { session : Maybe Api.Session
    , urlInput : String
    , emailInput : String
    , viewState : ViewState
    }



-- Init


init : Maybe Api.Session -> ( Model, Cmd Msg )
init maybeSession =
    let
        model =
            { session = maybeSession
            , urlInput = ""
            , emailInput = ""
            , viewState = AwaitingFeedUrlInput
            }
    in
    ( model, Cmd.none )



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
    = UrlInputChanged String
    | CreateFeed
    | FeedCreated (Result Http.Error Api.GetFeedResponse)
    | EmailInputChanged String
    | CreateEmailNotification String
    | EmailNotificationCreated (Result Http.Error ())


sourceFromUrlInput input =
    case Url.fromString input of
        Just url ->
            Source.fromUrl url

        Nothing ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
            ( { model | urlInput = "", viewState = FeedRequestMade Waiting }, cmd )

        FeedCreated (Ok response) ->
            ( { model | viewState = FeedRequestMade (Done response) }, Cmd.none )

        FeedCreated (Err error) ->
            ( { model | viewState = FeedRequestMade Error }, Cmd.none )

        EmailInputChanged input ->
            ( { model | emailInput = input }, Cmd.none )

        CreateEmailNotification feedId ->
            let
                cmd =
                    Api.createEmailNotification { email = model.emailInput, feedId = feedId }
                        |> Http.toTask
                        |> Task.attempt EmailNotificationCreated
            in
            ( { model | viewState = EmailNotificationRequestMade Waiting }, cmd )

        EmailNotificationCreated (Err _) ->
            ( { model | viewState = EmailNotificationRequestMade Error }, Cmd.none )

        EmailNotificationCreated (Ok response) ->
            ( { model | viewState = EmailNotificationRequestMade (Done response) }, Cmd.none )



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
                , href ("/rss/" ++ feed.id)
                , target "_blank"
                ]
                [ i [ class "fa fa-2x fa-rss pr-2" ] []
                , span [ class "font-bold text-2xl" ] [ text "RSS" ]
                ]
            , img [ class "h-8", src "http://oi63.tinypic.com/34njn82.jpg" ] []
            ]
        ]


viewError : Html Msg
viewError =
    div [ class "text-center" ]
        [ p [ class "font-bold text-2xl" ] [ text "Ut oh!" ]
        , i [ class "fa fa-5x fa-exclamation-circle my-4 text-red" ] []
        , p [] [ text "There was an error processing your request. Please try again." ]
        ]


viewEmailNotification : Bool -> Maybe String -> Html Msg
viewEmailNotification requestInFlight maybeFeedId =
    let
        formStyles =
            [ class "pt-4" ]

        formAttrs =
            formStyles
                ++ (case maybeFeedId of
                        Just feedId ->
                            [ onSubmit (CreateEmailNotification feedId) ]

                        Nothing ->
                            []
                   )
    in
    div [ class "text-center" ]
        [ p [ class "font-bold text-2xl pb-4" ] [ text "Ut oh!" ]
        , p [] [ text "This feed is taking longer to generate than expected." ]
        , p [] [ text "Enter your email below and we'll let you know when it's ready." ]
        , form formAttrs
            [ input
                [ class "pr-4 w-1/2 border-1 border-grey-light rounded text-grey-dark"
                , type_ "text"
                , onInput EmailInputChanged
                , disabled requestInFlight
                , placeholder "me@example.com"
                ]
                []
            , div [ class "pt-4" ]
                [ button
                    [ class "border-4 px-2 py-1 border-transparent text-white font-bold bg-green hover:bg-green-dark rounded-lg"
                    , disabled requestInFlight
                    ]
                    [ text "Notify me" ]
                ]
            ]
        ]


viewFeedRequest : RequestState Api.GetFeedResponse -> Html Msg
viewFeedRequest requestState =
    case requestState of
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
            viewError

        Done (Api.FeedNotReady feedId) ->
            viewEmailNotification False (Just feedId)

        Done (Api.GotFeed feed) ->
            feedPreview feed


viewEmailNotificationRequest requestState =
    case requestState of
        Waiting ->
            viewEmailNotification True Nothing

        Error ->
            viewError

        Done () ->
            div [ class "text-center" ]
                [ p [ class "font-bold text-2xl" ] [ text "Got it!" ]
                , i [ class "fa fa-5x fa-check-circle my-4 text-green" ] []
                , p [] [ text "We'll send you an email when we've finished processing your feed." ]
                ]


view : Model -> Browser.Document Msg
view model =
    let
        subview =
            case model.viewState of
                AwaitingFeedUrlInput ->
                    text ""

                FeedRequestMade requestState ->
                    viewFeedRequest requestState

                EmailNotificationRequestMade requestState ->
                    viewEmailNotificationRequest requestState
    in
    { title = "Home"
    , body =
        [ div [ class "flex container mx-auto my-auto h-screen font-sans" ]
            [ div [ class "mx-auto my-auto w-1/2" ]
                [ div [ class "rounded-xl shadow-lg px-6 pt-12 pb-4 bg-white" ]
                    [ feedUrlForm model.urlInput
                    , div [ class "mt-8" ]
                        [ subview
                        ]
                    ]
                ]
            ]
        ]
    }
