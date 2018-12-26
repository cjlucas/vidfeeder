module Style.Padding exposing (bottom, left, right, top, x, y)

import Style exposing (Style(..))


bottom =
    padding "pb"


left =
    padding "pl"


right =
    padding "pr"


top =
    padding "pt"


x =
    padding "px"


y =
    padding "py"


padding className size =
    ClassStyle (className ++ "-" ++ String.fromInt size)
