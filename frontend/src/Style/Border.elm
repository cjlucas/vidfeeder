module Style.Border exposing (all, bottom, left, none, right, top)


none =
    "border-none"


all size =
    borderSize "border" size


top size =
    borderSize "border-t" size


right size =
    borderSize "border-r" size


left size =
    borderSize "border-l" size


bottom size =
    borderSize "border-b" size


borderSize direction size =
    direction ++ "-" ++ String.fromInt size
