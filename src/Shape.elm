module Shape exposing (decodeShape)

import Json.Decode as Json


type alias Shape =
    {}


decodeShape : Json.Decoder Shape
decodeShape =
    Debug.crash ""
