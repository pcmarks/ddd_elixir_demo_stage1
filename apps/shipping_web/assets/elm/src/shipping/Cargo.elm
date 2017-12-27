module Cargo exposing (CargoResponse(..), Cargo)

import Delivery exposing (..)
import HandlingEvent as HE


type CargoResponse
    = CargoFound Cargo
    | CargoNotFound String


type alias Cargo =
    { trackingId : String
    , delivery : Delivery
    , handlingEventsList : HE.Model
    }


initCargo : Cargo
initCargo =
    (Cargo "" (Delivery.initModel) HE.initModel)
