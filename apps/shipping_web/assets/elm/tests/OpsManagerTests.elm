module OpsManagerTests exposing (..)

{--
--}

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import App
import Shipping
import OpsManager


chooseOpsManager : App.Model
chooseOpsManager =
    App.init
        |> App.update App.OpsManagerChosen
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
                    Expect.equal user App.OpsManagerUser
        ]
