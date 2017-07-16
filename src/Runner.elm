port module Runner exposing (main)

import Platform
import Json.Decode as Json
import Layer exposing (decodeLayer)


port parse : (String -> msg) -> Sub msg


port knownImages : (List String -> msg) -> Sub msg


port respond : String -> Cmd msg


type Msg
    = Parse String
    | KnownImages (List String)


type alias Model =
    { knownImages : List String }


decodeLayers : Json.Decoder (List Layer.Layer)
decodeLayers =
    Json.field "layers" (Json.list Layer.decodeLayer)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Parse value ->
            case Json.decodeString decodeLayers value of
                Err r ->
                    "unable to parse"
                        |> respond
                        |> (\x -> ( model, x ))

                Ok v ->
                    List.map (Layer.toElmHtml model.knownImages) v
                        |> (\divs -> "import Html\nimport Html.Attributes\n\n\nmain = Html.div [] [" ++ String.join "\n\n  ," divs ++ "]")
                        |> respond
                        |> (\x -> ( model, x ))

        KnownImages images ->
            ( { model | knownImages = images }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ parse Parse
        , knownImages KnownImages
        ]


main : Program Never Model Msg
main =
    Platform.program
        { init = ( { knownImages = [] }, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        }
