module Style exposing
    ( Style(..)
    , noAppearance
    , noOutline
    , opacity
    , shadowLarge
    , style
    , styleList
    )

import Html
import Html.Attributes exposing (class, classList)


type Style
    = ClassStyle String


style : List Style -> Html.Attribute msg
style styles =
    class <| String.join " " <| List.map asClass styles


styleList : List ( Style, Bool ) -> Html.Attribute msg
styleList styles =
    classList <|
        List.map (\( s, enabled ) -> ( asClass s, enabled )) styles


asClass style_ =
    case style_ of
        ClassStyle class ->
            class



-- APPEARANCE


noAppearance =
    ClassStyle "appearance-none"



-- OPACITY


opacity percentage =
    ClassStyle ("opacity-" ++ String.fromInt percentage)



-- OUTLINE


noOutline =
    ClassStyle "outline-none"



-- SHADOWS


shadowLarge =
    ClassStyle "shadow-lg"
