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
        , target
        , type_
        , value
        , width
        )
import Html.Events exposing (onInput, onSubmit)
import Http
import Icon
import Source exposing (Source, SourceName(..), SourceType)
import Spinner
import Style exposing (style, styleList)
import Style.Background as Background
import Style.Border as Border
import Style.Color as Color
import Style.Cursor as Cursor
import Style.Display as Display
import Style.Flex as Flex
import Style.Font as Font
import Style.Layout as Layout
import Style.Margin as Margin
import Style.Padding as Padding
import Style.Sizing as Sizing
import Style.State
import Style.Text as Text
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

                YoutubeDL ->
                    "youtube_dl"

        type_ =
            case source.sourceType of
                Source.User ->
                    "user"

                Source.Channel ->
                    "channel"

                Source.Playlist ->
                    "playlist"

                Source.URL ->
                    "url"
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


inputUrlValid inputUrl =
    let
        url =
            String.trim inputUrl
    in
    sourceFromUrlInput url /= Nothing


inputEmpty inputText =
    (String.length << String.trim) inputText == 0


feedUrlForm inputText =
    let
        urlValid =
            inputUrlValid inputText

        validUrlOrEmpty =
            urlValid || inputEmpty inputText
    in
    form
        [ style
            [ Display.flex
            , Flex.centerAlignItems
            , Padding.y 2
            , Border.bottom 1
            ]
        , styleList
            [ ( Border.color Color.lightGrey, validUrlOrEmpty )
            , ( Border.color Color.red, not validUrlOrEmpty )
            ]
        , onSubmit CreateFeed
        ]
        [ input
            [ style
                [ Sizing.fullWidth
                , Padding.right 4
                , Background.color Color.transparent
                , Border.none
                , Font.color Color.darkGrey
                , Style.State.focus Style.noOutline
                , Style.noAppearance
                ]
            , value inputText
            , type_ "text"
            , placeholder "Feed URL"
            , onInput UrlInputChanged
            ]
            []
        , button
            [ style
                [ Border.roundedLarge
                , Border.all 4
                , Padding.x 2
                , Padding.y 1
                , Border.color Color.transparent
                , Font.color Color.white
                , Background.color Color.blue
                , Style.State.hover (Background.color Color.darkBlue)
                , Font.bold
                ]
            , styleList
                [ ( Style.opacity 50, not urlValid )
                , ( Cursor.notAllowed, not urlValid )
                ]
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
                    img [ style [ Sizing.height 32, Sizing.width 32 ], src url ] []

                Nothing ->
                    text ""
    in
    div []
        [ div
            [ style
                [ Display.flex
                , Margin.bottom 4
                ]
            ]
            [ image
            , div [ style [ Padding.left 6 ] ]
                [ h1 [ style [ Margin.bottom 2 ] ] [ text title ]
                , text description
                ]
            ]
        , div
            [ style
                [ Display.flex
                , Flex.justifyBetween
                , Flex.centerAlignItems
                , Padding.top 2
                , Padding.bottom 2
                ]
            ]
            [ a
                [ style
                    [ Display.flex
                    , Flex.centerAlignItems
                    , Font.color Color.lightGrey
                    , Style.State.hover (Font.color Color.orange)
                    , Font.noUnderline
                    ]
                , href ("/rss/" ++ feed.id)
                , target "_blank"
                ]
                [ Icon.rss Icon.Medium [ style [ Padding.right 2 ] ]
                , span
                    [ style [ Font.bold, Font.xxl ] ]
                    [ text "RSS" ]
                ]
            , img [ style [ Sizing.height 8 ], src "http://oi63.tinypic.com/34njn82.jpg" ] []
            ]
        ]


viewError : Html Msg
viewError =
    div
        [ style [ Text.center ] ]
        [ p [ style [ Font.bold, Font.xxl ] ] [ text "Ut oh!" ]
        , Icon.exclamationCircle Icon.Large
            [ style
                [ Margin.y 4
                , Font.color Color.red
                ]
            ]
        , p [] [ text "There was an error processing your request. Please try again." ]
        ]


viewEmailNotification : Bool -> Maybe String -> Html Msg
viewEmailNotification requestInFlight maybeFeedId =
    let
        formStyles =
            [ style [ Padding.top 4 ] ]

        formAttrs =
            formStyles
                ++ (case maybeFeedId of
                        Just feedId ->
                            [ onSubmit (CreateEmailNotification feedId) ]

                        Nothing ->
                            []
                   )
    in
    div [ style [ Text.center ] ]
        [ p
            [ style
                [ Font.bold
                , Font.xxl
                , Padding.bottom 4
                ]
            ]
            [ text "Ut oh!" ]
        , p [] [ text "This feed is taking longer to generate than expected." ]
        , p [] [ text "Enter your email below and we'll let you know when it's ready." ]
        , form formAttrs
            [ input
                [ style
                    [ Border.rounded
                    , Sizing.halfWidth
                    , Padding.right 4
                    , Border.all 1
                    , Border.color Color.lightGrey
                    , Font.color Color.darkGrey
                    ]
                , type_ "text"
                , onInput EmailInputChanged
                , disabled requestInFlight
                , placeholder "me@example.com"
                ]
                []
            , div
                [ style [ Padding.top 4 ] ]
                [ button
                    [ style
                        [ Border.roundedLarge
                        , Background.color Color.green
                        , Style.State.hover (Background.color Color.darkGreen)
                        , Border.color Color.transparent
                        , Font.color Color.white
                        , Padding.x 2
                        , Padding.y 1
                        , Border.all 4
                        , Font.bold
                        ]
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
            div [ style [ Text.center ] ]
                [ p [ style [ Font.bold, Font.xxl ] ] [ text "We're working on it!" ]
                , Spinner.doubleBounce
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
            div [ style [ Text.center ] ]
                [ p [ style [ Font.bold, Font.xxl ] ] [ text "Got it!" ]
                , Icon.checkCircle Icon.Large
                    [ style
                        [ Margin.y 4
                        , Font.color Color.green
                        ]
                    ]
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
        [ div
            [ style
                [ Display.flex
                , Layout.container
                , Margin.autoX
                , Margin.autoY
                , Sizing.screenHeight
                , Font.sans
                ]
            ]
            [ div
                [ style
                    [ Margin.autoX
                    , Margin.autoY
                    , Sizing.halfWidth
                    ]
                ]
                [ div
                    [ style
                        [ Border.roundedExtraLarge
                        , Style.shadowLarge
                        , Padding.x 6
                        , Padding.top 12
                        , Padding.bottom 4
                        , Background.color Color.white
                        ]
                    ]
                    [ feedUrlForm model.urlInput
                    , div [ style [ Margin.top 8 ] ] [ subview ]
                    ]
                ]
            ]
        ]
    }
