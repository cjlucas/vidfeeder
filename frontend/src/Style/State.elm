module Style.State exposing (focus, hover)

import Style exposing (Style(..))


focus style =
    case style of
        ClassStyle class ->
            ClassStyle ("focus:" ++ class)


hover style =
    case style of
        ClassStyle class ->
            ClassStyle ("hover:" ++ class)
