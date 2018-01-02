module HandlingEvent exposing (HandlingEvent, Model, Response, initModel)

import Date exposing (Date)


type alias HandlingEvent =
    { voyage : String
    , eventType : String
    , trackingId : String
    , registrationTime : Date
    , completionTime : Date
    , location : String
    }


type alias Model =
    Maybe (List HandlingEvent)


type alias Response =
    { handling_events : List HandlingEvent }


initModel : Model
initModel =
    Nothing
