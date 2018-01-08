module OpsManagerTests exposing (..)

{--
--}

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Tracking
import Shipping
import OpsManager


chooseOpsManager : Tracking.Model
chooseOpsManager =
    Tracking.initModel
        |> Tracking.update Tracking.OpsManagerChosen
        |> Tuple.first


opsManagerChosen : Test
opsManagerChosen =
    describe "Various and sundry OpsManager tests"
        [ test "Choose OpsManager" <|
            \_ ->
                let
                    user =
                        chooseOpsManager |> .user
                in
                    Expect.equal user Tracking.OpsManagerUser
        ]
