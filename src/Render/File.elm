module Render.File exposing (toElmHtml)

import Layer exposing (..)
import Assets exposing (..)
import Render.Css exposing (..)


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


bitmapToElmHtml : List String -> LayerProps -> ImageProps -> String
bitmapToElmHtml knownImages layerProps image =
    frameToCss layerProps.frame
        ++ styleToCss layerProps.style
        ++ [ ( "z-index", "1" ) ]
        |> List.map (\( x, y ) -> "(\"" ++ x ++ "\", \"" ++ y ++ "\")")
        |> String.join "\n  , "
        |> (\x ->
                "Html.div [ Html.Attributes.style ["
                    ++ "] ]"
                    ++ " [ Html.img [ Html.Attributes.src \""
                    ++ identifySuffix knownImages image.src
                    ++ "\", Html.Attributes.style ["
                    ++ x
                    ++ "] ] [] ]"
           )


toElmHtml : List String -> Layer -> String
toElmHtml knownImages layer =
    case layer of
        Unknown stuff ->
            "Html.text \"\" -- I was unable to figure out what this layer was" ++ toString stuff

        Slice ->
            "Html.text \"\" -- Unsupported slice!"

        ShapeGroupLayer layerProps shapeGroup ->
            layerPropsToElmHtml layerProps

        TextLayer layerProps text ->
            textToElmHtml layerProps text

        BitmapLayer layerProps image ->
            bitmapToElmHtml knownImages layerProps image

        GroupLayer layers ->
            List.map (toElmHtml knownImages) layers
                |> String.join "\n  , "
                |> (\str -> "Html.div [] [" ++ str ++ "]")
