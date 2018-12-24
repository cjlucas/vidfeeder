module Style.Cursor exposing (notAllowed)


type CursorTypes
    = NotAllowed


notAllowed =
    cursor NotAllowed


cursor type_ =
    case type_ of
        NotAllowed ->
            "cursor-not-allowed"
