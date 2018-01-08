module DeliveryHistory exposing (DeliveryHistory, initModel)

{--
A Delivery History is the result of applying all the Handling Events
associated with a cargo. This is performed by the server resulting in this module's
response.
--}


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
