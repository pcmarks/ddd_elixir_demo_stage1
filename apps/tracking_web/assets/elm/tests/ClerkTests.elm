module ClerkTests exposing (..)

{--
--}

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import App
import Shipping
import Clerk
import Cargo


chooseClerk : App.Model
chooseClerk =
    App.init
        |> App.update App.ClerkChosen
        |> Tuple.first


clerkChosen : Test
clerkChosen =
    describe "Various and sundry Clerk tests"
        [ test "Choose Clerk" <|
            \_ ->
                let
                    user =
                        chooseClerk |> .user
                in
                    Expect.equal user App.ClerkUser
        ]
