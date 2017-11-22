module Shipping exposing (CargoResponse(..), Cargo, HandlingEvent)

import Date exposing (Date)


type CargoResponse
    = CargoFound Cargo
    | CargoNotFound String


type alias Cargo =
    { trackingId : String
    , handlingEventsList : Maybe (List HandlingEvent)
    }


initCargo : Cargo
initCargo =
    (Cargo "" Nothing)


type alias HandlingEvent =
    { voyage : String
    , event_type : String
    , tracking_id : String
    , registration_time : Date
    , completion_time : Date
    , location : String
    }
