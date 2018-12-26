module Style.Font exposing (bold, color, noUnderline, sans, xxl)

import Style exposing (Style(..))
import Style.Color as Color


bold =
    ClassStyle "font-bold"


noUnderline =
    ClassStyle "no-underline"


sans =
    ClassStyle "font-sans"


color color_ =
    ClassStyle ("text-" ++ Color.asClass color_)



-- SIZING


xxl =
    ClassStyle "text-2xl"
