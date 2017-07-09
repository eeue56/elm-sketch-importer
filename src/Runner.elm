port module Runner exposing (main)

import Platform
import Json.Decode as Json
import Layer exposing (decodeLayer)


port parse : (String -> msg) -> Sub msg


port respond : String -> Cmd msg


type Msg
    = Parse String


decodeLayers : Json.Decoder (List Layer.Layer)
decodeLayers =
    Json.field "layers" (Json.list Layer.decodeLayer)


update : Msg -> () -> ( (), Cmd Msg )
update (Parse value) _ =
    case Json.decodeString decodeLayers value of
        Err r ->
            "unable to parse"
                |> respond
                |> (\x -> ( (), x ))

        Ok v ->
            List.map Layer.toElmHtml v
                |> (\divs -> "import Html\nimport Html.Attributes\n\n\nmain = Html.div [] [" ++ String.join "\n\n  ," divs ++ "]")
                |> respond
                |> (\x -> ( (), x ))


subscriptions _ =
    parse Parse


main =
    Platform.program
        { init = ( (), Cmd.none )
        , update = update
        , subscriptions = subscriptions
        }
