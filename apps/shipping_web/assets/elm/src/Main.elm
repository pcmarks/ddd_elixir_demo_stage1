module Main exposing (..)

import Dom
import Html exposing (..)
import Html.Attributes exposing (class, id, type_, placeholder, style, src)
import Html.Events exposing (onClick, onInput)
import Http exposing (Request)
import Json.Decode exposing (Decoder, andThen, fail, int, list, maybe, map, oneOf, string, succeed)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode
import Task exposing (perform)
import Date exposing (Date)
import Date.Format


-- SUPPORTING MODULES
-- Core - common functions
-- Sytles - various and sundry Attribute class Styles

import Core exposing (..)
import Styles exposing (..)
import CustomerPage exposing (..)


-- MAIN PROGRAM


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- MODEL AND TYPES


type alias Model =
    { user : User
    , cargo : Cargo
    , cargoErrorMessage : Maybe String
    , handlingEventSource : HandlingEventSource
    }


type User
    = None
    | CustomerUser
    | ClerkUser


type alias HandlingEventSource =
    { newHandlingEvent : Maybe HandlingEvent
    , handlingEventList : Maybe HandlingEventList
    }


init : ( Model, Cmd msg )
init =
    ( Model None initCargo Nothing initClerk, Cmd.none )


initClerk : HandlingEventSource
initClerk =
    (HandlingEventSource Nothing Nothing)



-- VIEWS


view : Model -> Html Msg
view model =
    div []
        [ viewLogo
        , p [] []
        , div []
            (case model.user of
                None ->
                    viewUserChoice

                CustomerUser ->
                    viewCustomer model

                ClerkUser ->
                    viewClerk model.handlingEventSource
            )
        ]


viewLogo : Html Msg
viewLogo =
    div [ class row ]
        [ div [ class (colS4 "") ] [ p [] [] ]
        , div [ class (colS4 "w3-center") ]
            [ img [ src "images/ddd_logo.png", style logo, onClick Home ] []
            ]
        , div [ class (colS4 "") ] [ p [] [] ]
        , p [] []
        ]


viewUserChoice : List (Html Msg)
viewUserChoice =
    [ div [ class row ]
        [ div [ class (colS3 "") ] [ p [] [] ]
        , div [ class (colS6 "w3-center") ]
            [ div []
                [ h1
                    [ class ""
                    , style [ ( "font", "bolder" ), ( "color", "MidnightBlue" ) ]
                    ]
                    [ text "An Elm/Phoenix Demonstration" ]
                ]
            ]
        ]
    , div [ class row ]
        [ div [ class (colS3 "") ] [ p [] [] ]
        , div [ class (colS6 "w3-center") ]
            [ div []
                [ h3
                    [ class ""
                    , style [ ( "font", "bolder" ), ( "color", "MidnightBlue" ) ]
                    ]
                    [ text "Please Choose a User Type" ]
                ]
            ]
        ]
    , div [ class row ]
        [ div [ class (colS4 "") ] [ p [] [] ]
        , div [ class (colS4 "w3-center w3-padding-48"), style [ ( "background-color", "#fee" ) ] ]
            [ button [ class (buttonClassStr "w3-margin"), onClick CustomerChosen ] [ text "Customer" ]
            , button [ class (buttonClassStr "w3-margin"), onClick ClerkChosen ] [ text "Shipping Clerk" ]
            ]
        , div [ class (colS4 "") ] [ p [] [] ]
        ]
    ]


viewCustomer : Model -> List (Html Msg)
viewCustomer model =
    List.concat [ viewCustomerHeader, viewCustomerError model, viewCustomerDetail model.cargo ]


viewCustomerHeader : List (Html Msg)
viewCustomerHeader =
    [ div [ class row ]
        [ div [ class (colS3 "") ] [ p [] [] ]
        , div [ class (colS6 "w3-center") ]
            [ div []
                [ h1
                    [ class ""
                    , style [ ( "font", "bold" ), ( "color", "MidnightBlue" ) ]
                    ]
                    [ text "Customer" ]
                ]
            ]
        ]
    ]


viewCustomerError : Model -> List (Html Msg)
viewCustomerError model =
    case model.cargoErrorMessage of
        Just message ->
            [ div [ class row ]
                [ div [ class (colS3 "") ] [ p [] [] ]
                , div [ class (colS6 "w3-center") ]
                    [ h3 [] [ span [ class "w3-light-blue" ] [ text message ] ] ]
                ]
            , div [] [ p [] [] ]
            ]

        Nothing ->
            []


viewCustomerDetail : Cargo -> List (Html Msg)
viewCustomerDetail cargo =
    case cargo.handlingEventList of
        Nothing ->
            [ div [ class row ]
                [ div [ class colS2 ]
                    [ p [] [] ]
                , div [ class (colS8 "w3-center") ]
                    [ div [ class "w3-bar" ]
                        [ span
                            [ class "w3-bar-item"
                            , style [ ( "font", "bold" ), ( "color", "MidnightBlue" ) ]
                            ]
                            [ text "Enter your Tracking ID" ]
                        , input
                            [ class "w3-bar-item w3-border w3-round-large"

                            -- , style [ ( "width", "30em" ) ]
                            , id focusElement
                            , type_ "text"
                            , placeholder "e.g. ABC123, IJK456"
                            , onInput TrackingIdEntered
                            ]
                            []
                        , button [ class (buttonClassStr "w3-bar-item w3-margin-left"), onClick FindTrackingId ] [ text "Track! " ]
                        ]
                    ]
                , p [] []
                ]
            ]

        Just handlingEvents ->
            [ div [ class row ]
                [ div [ class colS2 ] [ p [] [] ]
                , div [ class (colS8 "") ]
                    [ h2 [] [ text "Cargo Tracking Details" ]
                    , div [ class "w3-panel w3-padding-small w3-border w3-border-black w3-round-large" ]
                        [ div [ class "w3-panel w3-blue" ]
                            [ h5 [ class "w3-right" ] [ text "In Transit" ] ]
                        , div [ class "w3-panel" ]
                            [ div [ class "w3-left" ] [ text ("Tracking Id: " ++ cargo.trackingId) ]
                            , div [ class "w3-right" ] [ text ("Status: " ++ cargo.status) ]
                            ]
                        ]
                    ]
                , div [ class colS2 ] [ p [] [] ]
                ]
            , div [ class row ]
                [ div [ class colS2 ] [ p [] [] ]
                , div [ class (colS8 "w3-padding-small"), style [ ( "background-color", "#fee" ) ] ]
                    [ h5 [] [ text "Shipment Progress" ] ]
                , div [ class colS2 ] [ p [] [] ]
                ]
            , div [ class row ]
                [ div [ class colS2 ] [ p [] [] ]
                , div [ class (colS8 "") ]
                    [ viewCustomerEventTable handlingEvents
                    ]
                , div [ class colS2 ] [ p [] [] ]
                ]
            , p [] []
            , div [ class row ]
                [ div [ class (colS4 "") ]
                    [ p [] []
                    ]
                , div [ class (colS4 "w3-center") ]
                    [ button [ class (buttonClassStr "w3-center"), onClick CustomerBack ] [ text "Back" ] ]
                ]
            ]


viewCustomerEventTable : List HandlingEvent -> Html Msg
viewCustomerEventTable handlingEventList =
    table [ class "w3-table w3-striped w3-border w3-border-black" ]
        [ thead [ class "w3-pale-yellow" ]
            [ tr []
                -- [ th [] [ text "Voyage No" ]
                [ th [] [ text "Location" ]
                , th [] [ text "Date" ]
                , th [] [ text "Local Time" ]
                , th [] [ text "Type" ]
                ]
            ]
        , tbody []
            (List.map viewCustomerEvent handlingEventList)
        ]


viewCustomerEvent : HandlingEvent -> Html Msg
viewCustomerEvent handlingEvent =
    tr []
        -- [ td [] [ text handlingEvent.voyage ]
        [ td [] [ text handlingEvent.location ]
        , td [] [ text (Date.Format.format "%Y-%m-%d" handlingEvent.completion_time) ]
        , td [] [ text (Date.Format.format "%H:%M:%S" handlingEvent.completion_time) ]
        , td [] [ text handlingEvent.event_type ]
        ]


viewClerk : HandlingEventSource -> List (Html Msg)
viewClerk handlingEventSource =
    viewClerkHeader :: viewClerkDetail handlingEventSource


viewClerkHeader : Html Msg
viewClerkHeader =
    div [ class row ]
        [ div [ class (colS3 "") ] [ p [] [] ]
        , div [ class (colS6 "w3-center") ]
            [ div []
                [ h1
                    [ style [ ( "font", "bolder" ), ( "color", "MidnightBlue" ) ]
                    ]
                    [ text "Shipping Clerk" ]
                ]
            ]
        ]


viewClerkDetail : HandlingEventSource -> List (Html Msg)
viewClerkDetail handlingEventSource =
    [ div [ class row ]
        [ div [ class colS1 ] [ p [] [] ]
        , div [ class colS10 ]
            [ h2 [] [ text "Handling Events List" ] ]
        , div [ class colS1 ] [ p [] [] ]
        ]
    , case handlingEventSource.handlingEventList of
        Nothing ->
            div [ class row ]
                [ div [ class colS1 ] [ p [] [] ]
                , div [ class colS10 ]
                    [ h5 [] [ text "No Handling Events Available" ] ]
                , div [ class colS1 ] [ p [] [] ]
                ]

        Just handlingEvents ->
            div [ class row ]
                [ div [ class colS1 ] [ p [] [] ]
                , div [ class colS10 ] [ viewHandlingEventTable handlingEvents ]
                , div [ class colS1 ] [ p [] [] ]
                ]
    , p [] []
    ]


viewHandlingEventTable : HandlingEventList -> Html Msg
viewHandlingEventTable handlingEventList =
    table [ class "w3-table w3-striped w3-border w3-border-black" ]
        [ thead [ class "w3-pale-yellow" ]
            [ tr []
                [ th [] [ text "Type" ]
                , th [] [ text "Location" ]
                , th [] [ text "Local Comp. Time" ]
                , th [] [ text "Local Reg. Time" ]
                , th [] [ text "Tracking Id" ]
                , th [] [ text "Voyage No" ]
                ]
            ]
        , tbody []
            (List.map viewHandlingEvent handlingEventList.handling_events)
        ]


viewHandlingEvent : HandlingEvent -> Html Msg
viewHandlingEvent handlingEvent =
    tr []
        [ td [] [ text handlingEvent.event_type ]
        , td [] [ text handlingEvent.location ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlingEvent.completion_time) ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlingEvent.registration_time) ]
        , td [] [ text handlingEvent.tracking_id ]
        , td [] [ text handlingEvent.voyage ]
        ]



-- MSG AND UPDATE


type Msg
    = NoOpMsg
    | Home
    | CustomerChosen
    | CustomerBack
    | ClerkChosen
    | TrackingIdEntered String
    | FindTrackingId
    | ReceivedCargo CargoResponse
    | ReceivedAllHandlingEvents HandlingEventList
    | JoinedChannel String
    | HttpError String
    | CustomerQueryFocusOk
    | CustomerQueryFocusNotOk



-- setFocus is used to bring the key input focus for an input element.
-- There are three uses of it for the Customer functionality


setFocus : Result error value -> Msg
setFocus result =
    case result of
        Ok _ ->
            CustomerQueryFocusOk

        Err _ ->
            CustomerQueryFocusNotOk


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOpMsg ->
            ( model, Cmd.none )

        Home ->
            ( { model
                | user = None
                , cargo = initCargo
                , handlingEventSource = initClerk
              }
            , Cmd.none
            )

        JoinedChannel channelName ->
            ( model, Cmd.none )

        CustomerChosen ->
            ( { model | user = CustomerUser }, Task.attempt setFocus (Dom.focus focusElement) )

        CustomerQueryFocusOk ->
            ( model, Cmd.none )

        CustomerQueryFocusNotOk ->
            ( model, Cmd.none )

        CustomerBack ->
            let
                cargo =
                    initCargo
            in
                ( { model | cargo = cargo }, Task.attempt setFocus (Dom.focus focusElement) )

        ClerkChosen ->
            -- Prefetch all of the Handling Events for the Clerk
            ( { model | user = ClerkUser }, getAllHandlingEvents )

        TrackingIdEntered trackingId ->
            let
                newCargo =
                    (Cargo trackingId "" Nothing)
            in
                ( { model | cargo = newCargo }, Cmd.none )

        FindTrackingId ->
            ( model, getCargo (Just model.cargo.trackingId) )

        ReceivedCargo cargoResponse ->
            case cargoResponse of
                CargoResponseValid cargo ->
                    ( { model | cargo = cargo, cargoErrorMessage = Nothing }, Cmd.none )

                CargoResponseError cargoErrorMessage ->
                    ( { model | cargo = initCargo, cargoErrorMessage = Just cargoErrorMessage }, Task.attempt setFocus (Dom.focus focusElement) )

        ReceivedAllHandlingEvents response ->
            let
                handlingEventSource =
                    model.handlingEventSource

                newHandlingEventSource =
                    HandlingEventSource Nothing (Just response)
            in
                ( { model | handlingEventSource = newHandlingEventSource }, Cmd.none )

        HttpError errorString ->
            ( model, Cmd.none )



-- SERVER (PHOENIX APP) INTERFACE - REQUESTS AND DECODERS


phoenixHostPortUrl : String
phoenixHostPortUrl =
    "http://localhost:4000"


getCargo : Maybe String -> Cmd Msg
getCargo trackingId =
    case trackingId of
        Just id ->
            Http.send
                (\result ->
                    case result of
                        Ok response ->
                            ReceivedCargo response

                        Err httpErr ->
                            HttpError (toString httpErr)
                )
                (cargoRequest id)

        Nothing ->
            getAllHandlingEvents


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


customersUrl : String
customersUrl =
    phoenixHostPortUrl ++ "/customers"


clerksUrl : String
clerksUrl =
    phoenixHostPortUrl ++ "/shipping/clerks"


cargoRequest : String -> Request CargoResponse
cargoRequest id =
    Http.get
        (customersUrl
            ++ "/cargoes"
            ++ "?_format=json&cargo_params[tracking_id]="
            ++ id
        )
        cargoResponseDecoder



-- Cargo Request Responses


type CargoResponse
    = CargoResponseError String
    | CargoResponseValid Cargo


cargoResponseDecoder =
    oneOf [ validCargoDecoder, errorCargoDecoder ]



-- Valid Cargo response


type alias CargoValidResponse =
    { cargo : Cargo }


validCargoDecoder =
    Json.Decode.map (\response -> CargoResponseValid response.cargo)
        cargoValidResponseDecoder


cargoValidResponseDecoder =
    decode CargoValidResponse
        |> (required "cargo" cargoDecoder)


cargoDecoder : Decoder Cargo
cargoDecoder =
    decode Cargo
        |> Pipeline.required "tracking_id" string
        |> Pipeline.required "status" string
        |> Pipeline.required "handling_events" (maybe (list handlingEventDecoder))



-- Cargo Error response


type alias CargoErrorResponse =
    { errorStatus : String }


errorCargoDecoder =
    Json.Decode.map (\response -> CargoResponseError response.errorStatus)
        cargoErrorResponseDecoder


cargoErrorResponseDecoder =
    decode CargoErrorResponse
        |> (required "error_status" string)


clerkEventsUrl : String
clerkEventsUrl =
    clerksUrl ++ "/events"


allHandlingEventsRequest : Request HandlingEventList
allHandlingEventsRequest =
    Http.get (clerkEventsUrl ++ "?_format=json") handlingEventListDecoder


foo =
    (list handlingEventDecoder)


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
