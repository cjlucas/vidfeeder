module Style.Padding exposing (bottom, left, right, top, x, y)


bottom size =
    padding "pb" size


left size =
    padding "pl" size


right size =
    padding "pr" size


top size =
    padding "pt" size


x size =
    padding "px" size


y size =
    padding "py" size


padding className size =
    className ++ "-" ++ String.fromInt size
