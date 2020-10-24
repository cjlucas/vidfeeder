module Source exposing (Source, SourceName(..), SourceType(..), between, fromUrl)

import Parser exposing ((|.), (|=), Parser, map, succeed)
import Url exposing (Url)
import Url.Parser exposing ((<?>), query, s)
import Url.Parser.Query as Query


type SourceName
    = YouTube
    | YoutubeDL


type SourceType
    = User
    | Channel
    | Playlist
    | URL


type alias Source =
    { sourceName : SourceName
    , sourceType : SourceType
    , sourceId : String
    }


validateLength : String -> Parser String
validateLength s =
    if String.length s > 0 then
        succeed s

    else
        Parser.problem "its empty"


skipThrough : String -> Parser ()
skipThrough s =
    Parser.chompUntil s
        |. Parser.symbol s


between : String -> String -> Parser String
between before after =
    succeed identity
        |. skipThrough before
        |= (Parser.getChompedString (Parser.chompUntilEndOr after)
                |> Parser.andThen validateLength
           )


parseUrlPath parser url =
    Parser.run parser url.path |> Result.toMaybe


parseYouTubePlaylist path url =
    Url.Parser.parse (s path <?> Query.string "list") url
        |> Maybe.andThen identity
        |> Maybe.map (Source YouTube Playlist)


fromUrl : Url -> Maybe Source
fromUrl url =
    Just <| Source YoutubeDL URL <| Url.toString (Debug.log "url" url)



--fromUrl : Url -> Maybe Source
--fromUrl url =
--oneOf
--[ parseUrlPath (map (Source YouTube Channel) (between "/channel/" "/"))
--, parseUrlPath (map (Source YouTube User) (between "/user/" "/"))
--, parseYouTubePlaylist "watch"
--, parseYouTubePlaylist "playlist"
--]
--url


type alias Matcher =
    Url -> Maybe Source


oneOf : List Matcher -> Url -> Maybe Source
oneOf matchers url =
    case matchers of
        [] ->
            Nothing

        matcher :: rest ->
            case matcher url of
                Just source ->
                    Just source

                Nothing ->
                    oneOf rest url
