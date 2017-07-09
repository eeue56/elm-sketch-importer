module Layer exposing (..)

import Json.Decode as Json
import Json.Encode
import Html
import Html.Attributes as HA
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

                    _ ->
                        Unknown (Json.Encode.string "")
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


frameToCss : Frame -> List ( String, String )
frameToCss frame =
    [ ( "position", "absolute" )
    , ( "left", toString frame.x ++ "px" )
    , ( "top", toString frame.y ++ "px" )
    , ( "width", toString frame.width ++ "px" )
    , ( "height", toString frame.height ++ "px" )
    ]


shapeStylingToCss : ShapeStyling -> List ( String, String )
shapeStylingToCss style =
    case style.fills of
        fill :: _ ->
            [ ( "background-color"
              , "rgba("
                    ++ toString (fill.color.red * 255 |> floor)
                    ++ ","
                    ++ toString (fill.color.green * 255 |> floor)
                    ++ ","
                    ++ toString (fill.color.blue * 255 |> floor)
                    ++ ","
                    ++ toString fill.color.alpha
                    ++ ")"
              )
            ]

        _ ->
            []


styleToCss : Style -> List ( String, String )
styleToCss style =
    case style of
        ShapeStyle shapeStyling ->
            shapeStylingToCss shapeStyling

        TextStyle textStyling ->
            []


layerPropsToHtml : LayerProps -> Html.Html msg
layerPropsToHtml props =
    frameToCss props.frame
        ++ styleToCss props.style
        |> (\x -> Html.div [ HA.style x ] [])


verticalFlip : Bool -> List ( String, String )
verticalFlip flipped =
    if flipped then
        [ ( "-moz-transform"
          , "scale(1, -1)"
          )
        , ( "-webkit-transform"
          , "scale(1, -1)"
          )
        , ( "-o-transform"
          , "scale(1, -1)"
          )
        , ( "-ms-transform"
          , "scale(1, -1)"
          )
        , ( "transform"
          , "scale(1, -1)"
          )
        ]
    else
        []


horizontalFlip : Bool -> List ( String, String )
horizontalFlip flipped =
    if flipped then
        [ ( "-moz-transform"
          , "scale(-1, 1)"
          )
        , ( "-webkit-transform"
          , "scale(-1, 1)"
          )
        , ( "-o-transform"
          , "scale(-1, 1)"
          )
        , ( "-ms-transform"
          , "scale(-1, 1)"
          )
        , ( "transform"
          , "scale(-1, 1)"
          )
        ]
    else
        []


textToHtml : LayerProps -> Text -> Html.Html msg
textToHtml layerProps text =
    frameToCss layerProps.frame
        ++ styleToCss layerProps.style
        ++ horizontalFlip text.isFlippedHorizontal
        ++ verticalFlip text.isFlippedVertical
        ++ [ ( "z-index", "1" ) ]
        |> (\x -> Html.div [ HA.style x ] [ Html.text text.attributedString ])


bitmapToHtml : LayerProps -> ImageProps -> Html.Html msg
bitmapToHtml layerProps image =
    frameToCss layerProps.frame
        ++ styleToCss layerProps.style
        ++ [ ( "z-index", "1" ) ]
        |> (\x -> Html.div [ HA.style x ] [ Html.img [ HA.src image.src, HA.alt image.name ] [] ])


debugLayer : Layer -> String
debugLayer layer =
    case layer of
        Unknown stuff ->
            "Unknown"

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


toHtml : Layer -> Html.Html msg
toHtml layer =
    case layer of
        Unknown stuff ->
            Html.text "Don't know"

        ShapeGroupLayer layerProps shapeGroup ->
            layerPropsToHtml layerProps

        TextLayer layerProps text ->
            textToHtml layerProps text

        BitmapLayer layerProps image ->
            bitmapToHtml layerProps image

        GroupLayer layers ->
            List.map toHtml layers
                |> Html.div []


layerPropsToElmHtml : LayerProps -> String
layerPropsToElmHtml props =
    frameToCss props.frame
        ++ styleToCss props.style
        |> List.map (\( x, y ) -> "(\"" ++ x ++ "\", \"" ++ y ++ "\")")
        |> String.join "\n  , "
        |> (\x -> "Html.div [ Html.Attributes.style [" ++ x ++ "] ] []")


textToElmHtml : LayerProps -> Text -> String
textToElmHtml layerProps text =
    frameToCss layerProps.frame
        ++ styleToCss layerProps.style
        ++ horizontalFlip text.isFlippedHorizontal
        ++ verticalFlip text.isFlippedVertical
        ++ [ ( "z-index", "1" ) ]
        |> List.map (\( x, y ) -> "(\"" ++ x ++ "\", \"" ++ y ++ "\")")
        |> String.join "\n  , "
        |> (\x -> "Html.div [ Html.Attributes.style [" ++ x ++ "] ] [ Html.text \"" ++ text.name ++ "\" ]")


bitmapToElmHtml : LayerProps -> ImageProps -> String
bitmapToElmHtml layerProps image =
    frameToCss layerProps.frame
        ++ styleToCss layerProps.style
        ++ [ ( "z-index", "1" ) ]
        |> List.map (\( x, y ) -> "(\"" ++ x ++ "\", \"" ++ y ++ "\")")
        |> String.join "\n  , "
        |> (\x ->
                "Html.div [ Html.Attributes.style ["
                    ++ "] ]"
                    ++ " [ Html.img [ Html.Attributes.src \""
                    ++ image.src
                    ++ ".png"
                    ++ "\", Html.Attributes.style ["
                    ++ x
                    ++ "] ] [] ]"
           )


toElmHtml : Layer -> String
toElmHtml layer =
    case layer of
        Unknown stuff ->
            "Html.text \"Don't know\""

        ShapeGroupLayer layerProps shapeGroup ->
            layerPropsToElmHtml layerProps

        TextLayer layerProps text ->
            textToElmHtml layerProps text

        BitmapLayer layerProps image ->
            bitmapToElmHtml layerProps image

        GroupLayer layers ->
            List.map toElmHtml layers
                |> String.join "\n  , "
                |> (\str -> "Html.div [] [" ++ str ++ "]")
