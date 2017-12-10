module Cargo exposing (CargoResponse(..), Cargo)

import HandlingEvent as HE


type CargoResponse
    = CargoFound Cargo
    | CargoNotFound String


type alias Cargo =
    { trackingId : String
    , status : String
    , handlingEventsList : HE.Model
    }


initCargo : Cargo
initCargo =
    (Cargo "" "" Nothing)
