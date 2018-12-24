module Style.Margin exposing (autoX, autoY, bottom, left, right, top, x, y)


autoX =
    "mx-auto"


autoY =
    "my-auto"


bottom size =
    margin "mb" size


left size =
    margin "ml" size


right size =
    margin "mr" size


top size =
    margin "mt" size


x size =
    margin "mx" size


y size =
    margin "my" size


margin className size =
    className ++ "-" ++ String.fromInt size
