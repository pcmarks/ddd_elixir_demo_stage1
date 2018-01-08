module Initialization exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Tracking
import Shipping


initialModels : Test
initialModels =
    describe "Initial Models values"
        [ test "Initial user type is NoUser" <|
            \_ ->
                let
                    user =
                        Tracking.initModel
                            |> .user
                in
                    Expect.equal user Tracking.NoUser
        , test "Check initModelial clerk model 1" <|
            \_ ->
                let
                    trackingId =
                        Tracking.initModel
                            |> .clerkModel
                            |> .trackingId
                in
                    Expect.equal trackingId ""
        , test "Check initial clerk model 2" <|
            \_ ->
                let
                    shippingModel =
                        Tracking.initModel
                            |> .clerkModel
                            |> .shippingModel
                in
                    Expect.equal shippingModel (Shipping.initModel)
        , test "Check initial shipping ops model 1" <|
            \_ ->
                let
                    searchChoice =
                        Tracking.initModel
                            |> .shippingOpsModel
                            |> .searchCriteria
                in
                    Expect.equal searchChoice "All"
        , test "Check initial shipping ops model 2" <|
            \_ ->
                let
                    shippingModel =
                        Tracking.initModel
                            |> .shippingOpsModel
                            |> .shippingModel
                in
                    Expect.equal shippingModel (Shipping.initModel)
        ]
