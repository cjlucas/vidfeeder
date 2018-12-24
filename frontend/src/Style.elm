module Style exposing
    ( appearanceNone
    , opacity
    , outlineNone
    , rounded
    , roundedExtraLarge
    , roundedLarge
    , shadowLarge
    , style
    , styleList
    )

import Html
import Html.Attributes exposing (class, classList)


style : List String -> Html.Attribute msg
style styles =
    class (String.join " " styles)


styleList : List ( String, Bool ) -> Html.Attribute msg
styleList styles =
    classList styles



-- APPEARANCE


appearanceNone =
    "appearance-none"



-- OPACITY


opacity percentage =
    "opacity-" ++ String.fromInt percentage



-- OUTLINE


outlineNone =
    "outline-none"



-- ROUNDING


rounded =
    "rounded"


roundedLarge =
    "rounded-lg"


roundedExtraLarge =
    "rounded-xl"



-- SHADOWS


shadowLarge =
    "shadow-lg"
