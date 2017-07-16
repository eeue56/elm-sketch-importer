module Render.Css exposing (..)

import Layer exposing (..)


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
