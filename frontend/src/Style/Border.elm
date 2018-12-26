module Style.Border exposing
    ( all
    , bottom
    , color
    , left
    , none
    , right
    , rounded
    , roundedExtraLarge
    , roundedLarge
    , top
    )

import Style exposing (Style(..))
import Style.Color as Color



-- SIZING


none =
    ClassStyle "border-none"


all =
    borderSize "border"


top =
    borderSize "border-t"


right =
    borderSize "border-r"


left =
    borderSize "border-l"


bottom =
    borderSize "border-b"


borderSize direction size =
    ClassStyle (direction ++ "-" ++ String.fromInt size)



-- ROUNDING


rounded =
    ClassStyle "rounded"


roundedLarge =
    ClassStyle "rounded-lg"


roundedExtraLarge =
    ClassStyle "rounded-xl"



-- STYLING


color : Color.Color -> Style
color color_ =
    ClassStyle ("border-" ++ Color.asClass color_)
