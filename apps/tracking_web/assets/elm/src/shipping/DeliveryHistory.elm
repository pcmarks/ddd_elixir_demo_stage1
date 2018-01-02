module DeliveryHistory exposing (DeliveryHistory, initModel)


type alias DeliveryHistory =
    { transportationStatus : String
    , location : String
    , voyage : String
    , misdirected : Bool
    , routingStatus : String
    }


initModel : DeliveryHistory
initModel =
    (DeliveryHistory "" "" "" False "")
