module Route exposing (Route(..), fromUrl)

import Url.Parser exposing (s, oneOf, map, parse)


type Route
    = Login
    | CreateUser
    | Home


fromUrl url =
    parse parser (defragmentUrl url) |> Maybe.withDefault Home


defragmentUrl url =
    let
        path =
            Maybe.withDefault "" url.fragment
    in
        { url | path = path, fragment = Nothing }


parser =
    oneOf
        [ map Login (s "login")
        , map CreateUser (s "create")
        ]
