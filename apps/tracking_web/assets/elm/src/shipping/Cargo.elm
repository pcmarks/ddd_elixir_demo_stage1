module Cargo exposing (CargoResponse(..), Cargo)

import DeliveryHistory exposing (..)
import HandlingEvent as HE


type CargoResponse
    = CargoFound Cargo
    | CargoNotFound String


type alias Cargo =
    { trackingId : String
    , delivery : DeliveryHistory
    , handlingEventsList : HE.Model
    }


initCargo : Cargo
initCargo =
    (Cargo "" (DeliveryHistory.initModel) HE.initModel)
