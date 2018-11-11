module Page.CreateUser exposing (init, update, view, Msg, OutMsg(..), Model)

import Browser
import Html exposing (a, button, div, form, input, label, text)
import Html.Attributes exposing (href, for, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Api
import Task


type alias Model =
    { emailInput : String
    , passwordInput : String
    , passwordConfirmationInput : String
    }


type Msg
    = EmailInputChanged String
    | PasswordInputChanged String
    | PasswordConfirmationChanged String
    | FormSubmitted
    | LoggedIn (Result Http.Error Api.Session)


type OutMsg
    = SessionCreated Api.Session
    | None



-- Init


init =
    { emailInput = ""
    , passwordInput = ""
    , passwordConfirmationInput = ""
    }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case Debug.log "CreateUserMsg" msg of
        EmailInputChanged text ->
            ( { model | emailInput = text }, Cmd.none, None )

        PasswordInputChanged text ->
            ( { model | passwordInput = text }, Cmd.none, None )

        PasswordConfirmationChanged text ->
            ( { model | passwordConfirmationInput = text }, Cmd.none, None )

        FormSubmitted ->
            let
                createUserTask =
                    Api.createUserRequest
                        model.emailInput
                        model.passwordInput
                        model.passwordConfirmationInput
                        |> Http.toTask

                createSessionTask =
                    Api.createSessionRequest
                        model.emailInput
                        model.passwordInput
                        |> Http.toTask

                cmd =
                    createUserTask
                        |> Task.andThen (\_ -> createSessionTask)
                        |> Task.attempt LoggedIn
            in
                ( model, Debug.log "cmd" cmd, None )

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


view model =
    { title = "Create Account"
    , body =
        [ div [] [ text "CREATE ACCOUNT" ]
        , form [ onSubmit FormSubmitted ]
            [ inputWithLabel "Email" "email" "text" EmailInputChanged
            , inputWithLabel "Password" "password" "password" PasswordInputChanged
            , inputWithLabel "Confirm Password" "password_confirmation" "password" PasswordConfirmationChanged
            , button [ type_ "submit" ] [ text "Submit" ]
            ]
        , a [ href "/login" ] [ text "Already have an account? Login" ]
        ]
    }
