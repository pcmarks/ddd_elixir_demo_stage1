module Rest exposing (Msg(..), findCargo)

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
    | HttpError String


phoenixHostPortUrl : String
phoenixHostPortUrl =
    "http://localhost:4000"



-- TODO: Change to clerksUrl and Change backend


customersUrl : String
customersUrl =
    phoenixHostPortUrl ++ "/customers"


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
    oneOf [ validCargoDecoder, errorCargoDecoder ]



-- Valid Cargo response


type alias FoundCargo =
    { cargo : Cargo }


validCargoDecoder =
    Json.Decode.map (\response -> CargoFound response.cargo)
        cargoValidDecoder


cargoValidDecoder =
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


errorCargoDecoder =
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
