module Layer exposing (..)

{-| This module contains the types and decoders for layers.
Most of the heavy work of generating is taken care of in `Render`

-}

import Json.Decode as Json
import Json.Encode
import Base64


type alias ShapeGroup =
    {}


type alias Frame =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    }


type alias Color =
    { alpha : Float
    , blue : Float
    , green : Float
    , red : Float
    }


type alias Fill =
    { color : Color }


type alias ShapeStyling =
    { fills : List Fill }


type alias TextStyling =
    {}


type Style
    = ShapeStyle ShapeStyling
    | TextStyle TextStyling


type alias LayerProps =
    { frame : Frame
    , style : Style
    }


type alias Text =
    { name : String
    , isFlippedVertical : Bool
    , isFlippedHorizontal : Bool
    , attributedString : String
    }


type alias ImageProps =
    { name : String
    , src : String
    }


type Layer
    = GroupLayer (List Layer)
    | ShapeGroupLayer LayerProps ShapeGroup
    | TextLayer LayerProps Text
    | Unknown Json.Value
    | BitmapLayer LayerProps ImageProps
    | Slice


decodeBase64 : Json.Decoder String
decodeBase64 =
    Json.string
        |> Json.andThen
            (\str ->
                case Base64.decode str of
                    Err e ->
                        Json.fail e

                    Ok str ->
                        Json.succeed str
            )


decodeLayer : Json.Decoder Layer
decodeLayer =
    Json.field "_class" Json.string
        |> Json.andThen
            (\class ->
                case class of
                    "shapeGroup" ->
                        decodeShapeGroupLayer

                    "text" ->
                        decodeTextLayer

                    "group" ->
                        decodeGroupLayer

                    "artboard" ->
                        decodeGroupLayer

                    "bitmap" ->
                        decodeBitmapLayer

                    "slice" ->
                        Json.succeed Slice

                    _ ->
                        Unknown (Json.Encode.string class)
                            |> Json.succeed
            )


decodeGroupLayer : Json.Decoder Layer
decodeGroupLayer =
    Json.map GroupLayer (Json.lazy (\_ -> Json.field "layers" <| Json.list decodeLayer))


decodeShapeGroupLayer : Json.Decoder Layer
decodeShapeGroupLayer =
    Json.map2 ShapeGroupLayer decodeLayerProps (Json.succeed {})


decodeTextLayer : Json.Decoder Layer
decodeTextLayer =
    Json.map2 TextLayer decodeLayerProps decodeText


decodeBitmapLayer : Json.Decoder Layer
decodeBitmapLayer =
    Json.map2 BitmapLayer decodeLayerProps decodeImageProps


decodeText : Json.Decoder Text
decodeText =
    Json.map4 Text
        (Json.field "name" Json.string)
        (Json.field "isFlippedVertical" Json.bool)
        (Json.field "isFlippedHorizontal" Json.bool)
        (Json.field "attributedString" <| Json.field "archivedAttributedString" <| Json.field "_archive" decodeBase64)


decodeImageProps : Json.Decoder ImageProps
decodeImageProps =
    Json.map2 ImageProps
        (Json.field "name" Json.string)
        (Json.field "image" <| Json.field "_ref" Json.string)


decodeLayerProps : Json.Decoder LayerProps
decodeLayerProps =
    Json.map2 LayerProps
        (Json.field "frame" decodeFrame)
        (Json.field "style" decodeStyle)


decodeFrame : Json.Decoder Frame
decodeFrame =
    Json.map4 Frame
        (Json.field "height" Json.float)
        (Json.field "width" Json.float)
        (Json.field "x" Json.float)
        (Json.field "y" Json.float)


decodeColor : Json.Decoder Color
decodeColor =
    Json.map4 Color
        (Json.field "alpha" Json.float)
        (Json.field "blue" Json.float)
        (Json.field "green" Json.float)
        (Json.field "red" Json.float)


decodeFill : Json.Decoder Fill
decodeFill =
    Json.map Fill
        (Json.field "color" decodeColor)


decodeShapeStyling : Json.Decoder ShapeStyling
decodeShapeStyling =
    Json.map ShapeStyling
        (Json.field "fills" <| Json.list decodeFill)


decodeStyle : Json.Decoder Style
decodeStyle =
    Json.oneOf
        [ Json.map ShapeStyle decodeShapeStyling
        , Json.map TextStyle <| Json.succeed {}
        ]


{-| Turns the given layer into some useful debug info in the form of text
-}
debugLayer : Layer -> String
debugLayer layer =
    case layer of
        Unknown stuff ->
            "Unknown"

        Slice ->
            "Unsupported: slice"

        ShapeGroupLayer props group ->
            ""

        TextLayer props text ->
            "Text " ++ text.attributedString

        GroupLayer layers ->
            List.map debugLayer layers
                |> String.join ", "
                |> (++) "Layer\n"

        BitmapLayer layer image ->
            "Image " ++ image.name
