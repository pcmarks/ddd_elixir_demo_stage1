module Shipping exposing (CargoResponse(..), Cargo, HandlingEvent, HandlingEventList)

import Date exposing (Date)


type CargoResponse
    = CargoFound Cargo
    | CargoNotFound String


type alias Cargo =
    { trackingId : String
    , status : String
    , handlingEventsList : Maybe (List HandlingEvent)
    }


type alias HandlingEventList =
    { handling_events : List HandlingEvent }


type alias HandlingEvent =
    { voyage : String
    , event_type : String
    , tracking_id : String
    , registration_time : Date
    , completion_time : Date
    , location : String
    }


initCargo : Cargo
initCargo =
    (Cargo "" "" Nothing)
