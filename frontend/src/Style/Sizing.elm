module Style.Sizing exposing (fullWidth, halfWidth, height, screenHeight, width)


fullWidth =
    "w-full"


halfWidth =
    "w-1/2"


width n =
    "w-" ++ String.fromInt n


height n =
    "h-" ++ String.fromInt n


screenHeight =
    "h-screen"
