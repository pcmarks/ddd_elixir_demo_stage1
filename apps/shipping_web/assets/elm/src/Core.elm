module Core exposing (..)

import Date exposing (Date)


type alias HandlingEvent =
    { voyage : String
    , event_type : String
    , tracking_id : String
    , registration_time : Date
    , completion_time : Date
    , location : String
    }


type alias HandlingEventList =
    { handling_events : List HandlingEvent }


type alias Cargo =
    { trackingId : String
    , status : String
    , handlingEventList : Maybe (List HandlingEvent)
    }


initCargo : Cargo
initCargo =
    (Cargo "" "" Nothing)
