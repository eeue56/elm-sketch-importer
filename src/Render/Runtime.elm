module Render.Runtime exposing (toHtml)

import Html
import Html.Attributes as HA
import Layer exposing (..)
import Render.Css exposing (..)


layerPropsToHtml : LayerProps -> Html.Html msg
layerPropsToHtml props =
    frameToCss props.frame
        ++ styleToCss props.style
        |> (\x -> Html.div [ HA.style x ] [])


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


{-| Turns a sketch layer into a Html value at runtime

-}
toHtml : Layer -> Html.Html msg
toHtml layer =
    case layer of
        Unknown stuff ->
            Html.text "Don't know. Please open an issue on Github!"

        Slice ->
            Html.text "Unsupported slice. Please open an issue on Github!"

        ShapeGroupLayer layerProps shapeGroup ->
            layerPropsToHtml layerProps

        TextLayer layerProps text ->
            textToHtml layerProps text

        BitmapLayer layerProps image ->
            bitmapToHtml layerProps image

        GroupLayer layers ->
            List.map toHtml layers
                |> Html.div []
