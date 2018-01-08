module ClerkTests exposing (..)

{--
--}

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Tracking
import Shipping
import Clerk
import Cargo


chooseClerk : Tracking.Model
chooseClerk =
    Tracking.init
        |> Tracking.update Tracking.ClerkChosen
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
                    Expect.equal user Tracking.ClerkUser
        ]
