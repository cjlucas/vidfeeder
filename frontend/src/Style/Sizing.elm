module Style.Sizing exposing (fullWidth, halfWidth, height, screenHeight, width)

import Style exposing (Style(..))


fullWidth =
    ClassStyle "w-full"


halfWidth =
    ClassStyle "w-1/2"


width n =
    ClassStyle ("w-" ++ String.fromInt n)


height n =
    ClassStyle ("h-" ++ String.fromInt n)


screenHeight =
    ClassStyle "h-screen"
