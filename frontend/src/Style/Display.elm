module Style.Display exposing (block, flex)


type DisplayTypes
    = Flex
    | Block


flex =
    display Flex


block =
    display Block


display type_ =
    case type_ of
        Flex ->
            "flex"

        Block ->
            "block"
