module Icon exposing (Size(..), checkCircle, exclamationCircle, rss)

import Html exposing (Html, i)
import Html.Attributes exposing (class)


type Size
    = Small
    | Medium
    | Large


checkCircle =
    icon "fa-check-circle"


exclamationCircle =
    icon "fa-exclamation-circle"


rss : Size -> List (Html.Attribute msg) -> Html msg
rss =
    icon "fa-rss"


icon iconClass size attributes =
    let
        classes =
            String.join " " [ "fa", iconClass, sizeClass size ]
    in
    i (attributes ++ [ class classes ]) []


sizeClass size =
    case size of
        Small ->
            "fa-1x"

        Medium ->
            "fa-2x"

        Large ->
            "fa-5x"
