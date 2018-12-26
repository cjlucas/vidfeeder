module Style.Color exposing
    ( Color
    , asClass
    , blue
    , darkBlue
    , darkGreen
    , darkGrey
    , green
    , grey
    , lightGrey
    , orange
    , red
    , transparent
    , white
    )


type Color
    = Color String


red =
    Color "red"


blue =
    Color "blue"


darkBlue =
    Color "blue-dark"


green =
    Color "green"


darkGreen =
    Color "green-dark"


orange =
    Color "orange"


lightGrey =
    Color "grey-light"


grey =
    Color "grey"


darkGrey =
    Color "grey-dark"


white =
    Color "white"


transparent =
    Color "transparent"


asClass (Color str) =
    str
