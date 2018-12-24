module Style.Text exposing (Size(..), center, xxl)

-- ALIGNMENT


type Alignment
    = Center


center =
    align Center


align alignment =
    case alignment of
        Center ->
            "text-center"



-- SIZING


type Size
    = XxLarge


xxl =
    size XxLarge


size sz =
    case sz of
        XxLarge ->
            "text-2xl"
