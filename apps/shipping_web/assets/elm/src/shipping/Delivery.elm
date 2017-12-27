module Delivery exposing (Delivery, initModel)


type alias Delivery =
    { transportationStatus : String
    , location : String
    , voyage : String
    , misdirected : Bool
    , routingStatus : String
    }


initModel : Delivery
initModel =
    (Delivery "" "" "" False "")
