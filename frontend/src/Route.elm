module Route exposing (Route(..), fromUrl)

import Url.Parser exposing (s, oneOf, map, parse, top)


type Route
    = Login
    | CreateUser
    | Home


fromUrl url =
    parse parser url |> Maybe.withDefault Home


parser =
    oneOf
        [ map Home top
        , map Login (s "login")
        , map CreateUser (s "create")
        ]
