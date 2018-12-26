module Style.Background exposing (color)

import Style exposing (Style(..))
import Style.Color as Color


color color_ =
    ClassStyle ("bg-" ++ Color.asClass color_)
