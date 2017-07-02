module Layer exposing (..)

import Json.Decode as Json
import Json.Encode
import Html
import Html.Attributes as HA


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
    }


type Layer
    = ShapeGroupLayer LayerProps ShapeGroup
    | TextLayer LayerProps Text
    | Unknown Json.Value


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

                    _ ->
                        Unknown (Json.Encode.string "")
                            |> Json.succeed
            )


decodeShapeGroupLayer : Json.Decoder Layer
decodeShapeGroupLayer =
    Json.map2 ShapeGroupLayer decodeLayerProps (Json.succeed {})


decodeTextLayer : Json.Decoder Layer
decodeTextLayer =
    Json.map2 TextLayer decodeLayerProps decodeText


decodeText : Json.Decoder Text
decodeText =
    Json.map3 Text
        (Json.field "name" Json.string)
        (Json.field "isFlippedVertical" Json.bool)
        (Json.field "isFlippedHorizontal" Json.bool)


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
        |> (\x -> Html.div [ HA.style x ] [ Html.text text.name ])


toHtml : Layer -> Html.Html msg
toHtml layer =
    case layer of
        Unknown stuff ->
            Html.text "Don't know"

        ShapeGroupLayer layerProps shapeGroup ->
            layerPropsToHtml layerProps

        TextLayer layerProps text ->
            textToHtml layerProps text