module Spinner exposing (doubleBounce)

import Html exposing (Html, div)
import Html.Attributes exposing (class)


doubleBounce : Html msg
doubleBounce =
    div [ class "sk-double-bounce" ]
        [ div [ class "sk-child sk-double-bounce1" ] []
        , div [ class "sk-child sk-double-bounce2" ] []
        ]
