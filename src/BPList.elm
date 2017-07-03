module BPList exposing (..)

{-| -}


type PList
    = PList


parse : String -> Result String PList
parse str =
    if isBPList str then
        let
            _ =
                Debug.log "trailer" <| str
        in
            Ok PList
    else
        Err "Header did not start with bplist"


trailer : String -> String
trailer =
    String.right 16


isBPList : String -> Bool
isBPList head =
    String.startsWith "bplist" head
