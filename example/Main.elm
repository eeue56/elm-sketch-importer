module Main exposing (..)

import Html
import Json.Decode as Json
import Layer
import Render.Runtime
import SketchExample


decodeLayers : Json.Decoder (List Layer.Layer)
decodeLayers =
    Json.field "layers" (Json.list Layer.decodeLayer)


main : Html.Html msg
main =
    case Json.decodeString decodeLayers SketchExample.json of
        Err r ->
            Html.text r

        Ok v ->
            List.map Render.Runtime.toHtml v
                |> Html.div []
