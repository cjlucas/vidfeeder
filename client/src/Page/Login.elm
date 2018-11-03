module Page.Login exposing (init, update, view, Msg, OutMsg(..), Model)

import Api
import Browser
import Html exposing (a, button, div, form, input, label, text)
import Html.Attributes exposing (href, for, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http


type alias Model =
    { emailInput : String
    , passwordInput : String
    }


type Msg
    = EmailInputChanged String
    | PasswordInputChanged String
    | FormSubmitted
    | LoggedIn (Result Http.Error Api.Session)


type OutMsg
    = None
    | SessionCreated Api.Session



-- Init


init : Model
init =
    { emailInput = "", passwordInput = "" }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        EmailInputChanged text ->
            ( { model | emailInput = text }, Cmd.none, None )

        PasswordInputChanged text ->
            ( { model | passwordInput = text }, Cmd.none, None )

        FormSubmitted ->
            let
                cmd =
                    Http.send LoggedIn <|
                        Api.createSessionRequest
                            model.emailInput
                            model.passwordInput
            in
                ( model, cmd, None )

        LoggedIn (Ok session) ->
            ( model, Cmd.none, SessionCreated session )

        LoggedIn (Err error) ->
            ( model, Cmd.none, None )



-- View


inputWithLabel labelText id inputType inputChangedMsg =
    div []
        [ label [ for id ] [ text labelText ]
        , input
            [ type_ inputType
            , onInput inputChangedMsg
            ]
            []
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Login"
    , body =
        [ div []
            [ form [ onSubmit FormSubmitted ]
                [ inputWithLabel "Email" "email" "text" EmailInputChanged
                , inputWithLabel "Password" "password" "password" PasswordInputChanged
                , button [ type_ "submit" ] [ text "Submit" ]
                ]
            , a [ href "/create" ] [ text "New user? Create an account" ]
            ]
        ]
    }
