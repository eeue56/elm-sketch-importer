module TestBPList exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string)
import Test exposing (..)
import BPList exposing (PList)
import Base64


validAttribute : String
validAttribute =
    """
YnBsaXN0MDDUAQIDBAUGVFVYJHZlcnNpb25YJG9iamVjdHNZJGFyY2hpdmVyVCR0b3ASAAGGoK8QFQcIDxAcHR4fJSszNjpCQ0RFRkpOUFUkbnVsbNMJCgsMDQ5YTlNTdHJpbmdWJGNsYXNzXE5TQXR0cmlidXRlc4ACgBSAA1tIZWxsbyBXb3JsZNMREgoTFxtXTlMua2V5c1pOUy5vYmplY3RzoxQVFoAEgAWABqMYGRqAB4AJgAuAE1dOU0NvbG9yXxAQTlNQYXJhZ3JhcGhTdHlsZV8QH01TQXR0cmlidXRlZFN0cmluZ0ZvbnRBdHRyaWJ1dGXTICEKIiMkV05TV2hpdGVcTlNDb2xvclNwYWNlQjAAEAOACNImJygpWiRjbGFzc25hbWVYJGNsYXNzZXNXTlNDb2xvcqIoKlhOU09iamVjdNQsLS4KLzAxMlpOU1RhYlN0b3BzW05TQWxpZ25tZW50XxAfTlNBbGxvd3NUaWdodGVuaW5nRm9yVHJ1bmNhdGlvboAAEAQQAYAK0iYnNDVfEBBOU1BhcmFncmFwaFN0eWxlojQq0go3ODlfEBpOU0ZvbnREZXNjcmlwdG9yQXR0cmlidXRlc4ASgAzTERIKOz5Bojw9gA2ADqI
"""
        |> String.trim
        |> Base64.decode
        |> Result.withDefault ""


suite : Test
suite =
    describe "BPList"
        [ test "a valid header results in an empty object"
            (\_ ->
                validAttribute
                    |> BPList.parse
                    |> Expect.equal (Ok BPList.PList)
            )
        , test "an invalid header results in a readable error"
            (\_ ->
                BPList.parse "fgad"
                    |> Expect.equal (Err "Header did not start with bplist")
            )
        ]
