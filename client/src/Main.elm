module Main exposing (..)

import Api
import Browser
import Browser.Navigation as Nav
import Html exposing (div, text)
import Url exposing (Url)
import Json.Decode
import Route exposing (Route(..))
import Page.Login
import Page.CreateUser
import Page.Home


type Msg
    = UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | LoginMsg Page.Login.Msg
    | CreateUserMsg Page.CreateUser.Msg
    | HomeMsg Page.Home.Msg


type Page
    = LoginPage Page.Login.Model
    | CreateUserPage Page.CreateUser.Model
    | HomePage Page.Home.Model


type alias Model =
    { key : Nav.Key
    , session : Maybe Api.Session
    , currentPage : Page
    }


init flags url key =
    let
        model =
            { key = key
            , session = Nothing
            , currentPage = loadPage url
            }
    in
        ( model, Cmd.none )


loadPage : Url -> Page
loadPage url =
    case Route.fromUrl url of
        Login ->
            LoginPage Page.Login.init

        CreateUser ->
            CreateUserPage Page.CreateUser.init

        Home ->
            let
                ( model, _ ) =
                    Page.Home.init Nothing
            in
                HomePage model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( Debug.log "msg" msg, model.currentPage ) of
        ( UrlRequested (Browser.Internal url), _ ) ->
            let
                fragmentUrl =
                    { url | fragment = Just url.path, path = "" }

                cmd =
                    Nav.pushUrl model.key (Url.toString fragmentUrl)
            in
                ( { model | currentPage = loadPage fragmentUrl }, cmd )

        ( CreateUserMsg pageMsg, CreateUserPage pageModel ) ->
            let
                ( newPageModel, pageCmd, outMsg ) =
                    Page.CreateUser.update pageMsg pageModel

                currentPage =
                    CreateUserPage newPageModel

                ( newModel, cmd ) =
                    case outMsg of
                        Page.CreateUser.SessionCreated session ->
                            let
                                ( homePageModel, homePageCmd ) =
                                    Page.Home.init (Just session)
                            in
                                ( { model | currentPage = HomePage homePageModel }, Cmd.map HomeMsg homePageCmd )

                        Page.CreateUser.None ->
                            ( { model | currentPage = CreateUserPage newPageModel }, Cmd.map CreateUserMsg pageCmd )
            in
                ( newModel, cmd )

        ( LoginMsg pageMsg, LoginPage pageModel ) ->
            let
                ( newPageModel, pageCmd, outMsg ) =
                    Page.Login.update pageMsg pageModel

                ( newModel, cmd ) =
                    case outMsg of
                        Page.Login.SessionCreated session ->
                            let
                                ( homePageModel, homePageCmd ) =
                                    Page.Home.init (Just session)
                            in
                                ( { model | currentPage = HomePage homePageModel }, Cmd.map HomeMsg homePageCmd )

                        Page.Login.None ->
                            ( { model | currentPage = LoginPage newPageModel }, Cmd.map LoginMsg pageCmd )
            in
                ( newModel, cmd )

        ( HomeMsg pageMsg, HomePage pageModel ) ->
            let
                ( newPageModel, pageCmd ) =
                    Page.Home.update pageMsg pageModel

                newModel =
                    { model | currentPage = HomePage newPageModel }
            in
                ( newModel, Cmd.map HomeMsg pageCmd )

        _ ->
            ( model, Cmd.none )


subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    let
        updatePage viewer pageMsg pageModel =
            let
                { title, body } =
                    viewer pageModel
            in
                { title = title
                , body = List.map (Html.map pageMsg) body
                }
    in
        case Debug.log "currentPage" model.currentPage of
            LoginPage pageModel ->
                updatePage Page.Login.view LoginMsg pageModel

            CreateUserPage pageModel ->
                updatePage Page.CreateUser.view CreateUserMsg pageModel

            HomePage pageModel ->
                updatePage Page.Home.view HomeMsg pageModel


main : Program Json.Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }
