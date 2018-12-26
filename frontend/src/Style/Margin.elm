module Style.Margin exposing (autoX, autoY, bottom, left, right, top, x, y)

import Style exposing (Style(..))


autoX =
    ClassStyle "mx-auto"


autoY =
    ClassStyle "my-auto"


bottom =
    margin "mb"


left =
    margin "ml"


right =
    margin "mr"


top =
    margin "mt"


x =
    margin "mx"


y =
    margin "my"


margin className size =
    ClassStyle (className ++ "-" ++ String.fromInt size)
