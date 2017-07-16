module Assets exposing (..)

{-| Used to figure out the file name we should put in generated code
    identifySuffix ["hello.png"] "hello"
    --> "hello.png"

    identifySuffix [ "a.png", "ab.jpg"] "ab"
    --> "ab.jpg"

    identifySuffix [] "a"
    --> "a"
-}


identifySuffix : List String -> String -> String
identifySuffix knownImages imagePrefix =
    knownImages
        |> List.filterMap
            (\x ->
                case String.split "." x of
                    [] ->
                        Nothing

                    y :: ys ->
                        if y == imagePrefix then
                            Just x
                        else
                            Nothing
            )
        |> List.head
        |> Maybe.withDefault imagePrefix
