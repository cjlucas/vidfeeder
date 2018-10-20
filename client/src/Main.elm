module Main exposing (..)

import Browser
import Html exposing (div, text)


main =
    Browser.sandbox { init = 0, view = view, update = update }


update model =
    model


view model =
    div [] [ text "hi" ]
