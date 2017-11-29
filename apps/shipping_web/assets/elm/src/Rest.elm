module Rest exposing (Msg(..), findCargo, getAllHandlingEvents)

import Http exposing (Request)
import Json.Decode exposing (Decoder, andThen, fail, int, list, maybe, map, oneOf, string, succeed)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode
import Date exposing (Date)
import Date.Format


-- Local Imports

import Shipping exposing (..)


type alias HandlingEventList =
    { handling_events : List HandlingEvent }


type Msg
    = ReceivedCargo CargoResponse
    | ReceivedAllHandlingEvents HandlingEventList
    | HttpError String


phoenixHostPortUrl : String
phoenixHostPortUrl =
    "http://localhost:4000"



-- TODO: Change to clerksUrl and Change backend


customersUrl : String
customersUrl =
    phoenixHostPortUrl ++ "/clerks"


findCargo : String -> Cmd Msg
findCargo trackingId =
    Http.send
        (\result ->
            case result of
                Ok response ->
                    ReceivedCargo response

                Err httpErr ->
                    HttpError (toString httpErr)
        )
        (cargoRequest trackingId)


cargoRequest : String -> Request CargoResponse
cargoRequest id =
    Http.get
        (customersUrl
            ++ "/cargoes"
            ++ "?_format=json&cargo_params[tracking_id]="
            ++ id
        )
        cargoResponseDecoder



-- Cargo Request Decoder


cargoResponseDecoder =
    oneOf [ validCargoDecoder, invalidCargoDecoder ]



-- Valid Cargo response


type alias FoundCargo =
    { cargo : Cargo }


validCargoDecoder =
    Json.Decode.map (\response -> CargoFound response.cargo)
        cargoFieldDecoder


cargoFieldDecoder =
    decode FoundCargo
        |> (required "cargo" cargoDecoder)


cargoDecoder : Decoder Cargo
cargoDecoder =
    decode Cargo
        |> Pipeline.required "tracking_id" string
        |> Pipeline.required "status" string
        |> Pipeline.required "handling_events" (maybe (list handlingEventDecoder))



-- Cargo Error response


type alias CargoFoundNot =
    { errorStatus : String }


invalidCargoDecoder =
    Json.Decode.map (\response -> CargoNotFound response.errorStatus)
        cargoErrorResponseDecoder


cargoErrorResponseDecoder =
    decode CargoFoundNot
        |> (required "error_status" string)


handlingEventListDecoder : Decoder HandlingEventList
handlingEventListDecoder =
    decode HandlingEventList
        |> Pipeline.required "handling_events" (list handlingEventDecoder)


handlingEventDecoder : Decoder HandlingEvent
handlingEventDecoder =
    decode HandlingEvent
        |> Pipeline.required "voyage" string
        |> Pipeline.required "type" string
        |> Pipeline.required "tracking_id" string
        |> Pipeline.required "registration_time" date
        |> Pipeline.required "completion_time" date
        |> Pipeline.required "location" string



--- SysOps (Clerks) requests, and responses


clerksUrl : String
clerksUrl =
    phoenixHostPortUrl ++ "/shipping/clerks"


clerkEventsUrl : String
clerkEventsUrl =
    clerksUrl ++ "/events"


getAllHandlingEvents : Cmd Msg
getAllHandlingEvents =
    Http.send
        (\result ->
            case result of
                Ok response ->
                    ReceivedAllHandlingEvents response

                Err httpErr ->
                    HttpError (toString httpErr)
        )
        allHandlingEventsRequest


allHandlingEventsRequest : Request HandlingEventList
allHandlingEventsRequest =
    Http.get (clerkEventsUrl ++ "?_format=json") handlingEventListDecoder



-- handlingEventListDecoder : Decoder HandlingEventList
-- handlingEventListDecoder =
--     decode HandlingEventList
--         |> Pipeline.required "handling_events" (list handlingEventDecoder)
--
--
-- handlingEventDecoder : Decoder HandlingEvent
-- handlingEventDecoder =
--     decode HandlingEvent
--         |> Pipeline.required "voyage" string
--         |> Pipeline.required "type" string
--         |> Pipeline.required "tracking_id" string
--         |> Pipeline.required "registration_time" date
--         |> Pipeline.required "completion_time" date
--         |> Pipeline.required "location" string
--


date : Decoder Date
date =
    let
        convert : String -> Decoder Date
        convert raw =
            case Date.fromString raw of
                Ok date ->
                    succeed date

                Err error ->
                    fail error
    in
        string |> andThen convert
