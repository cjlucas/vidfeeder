module Style.Color exposing (Color(..), background, border, text)


type Color
    = Red
    | Blue
    | DarkBlue
    | Green
    | DarkGreen
    | Orange
    | LightGrey
    | Grey
    | DarkGrey
    | White
    | Transparent


text color =
    "text-" ++ strColor color


background color =
    "bg-" ++ strColor color


border color =
    "border-" ++ strColor color


strColor color =
    case color of
        Red ->
            "red"

        Blue ->
            "blue"

        DarkBlue ->
            "blue-dark"

        Green ->
            "green"

        DarkGreen ->
            "green-dark"

        Orange ->
            "orange"

        LightGrey ->
            "grey-light"

        Grey ->
            "grey"

        DarkGrey ->
            "grey-dark"

        White ->
            "white"

        Transparent ->
            "transparent"
