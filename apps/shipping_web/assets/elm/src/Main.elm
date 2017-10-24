module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, type_, placeholder, style, src)
import Html.Events exposing (onClick, onInput)
import Http exposing (Request)
import Json.Decode exposing (map, int, string, list, Decoder, andThen, succeed, fail)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
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
        , subscriptions = subscriptions
        }



-- MODEL AND TYPES


type alias Model =
    { user : User
    , cargo : Cargo
    , handlingEventSource : HandlingEventSource
    , phxSocket : Phoenix.Socket.Socket Msg
    }


type User
    = None
    | CustomerUser
    | HandlerUser


type alias HandlingEventSource =
    { handlingEventSourceMode : HandlerMode
    , newHandlingEvent : Maybe HandlingEvent
    , handlingEventList : Maybe HandlingEventList
    }


type HandlerMode
    = ListEvents
    | NewEvent


init : ( Model, Cmd msg )
init =
    ( Model None initCargo initHandler (initWebSocket), Cmd.none )


initHandler : HandlingEventSource
initHandler =
    (HandlingEventSource ListEvents Nothing Nothing)



-- initWebSocket : Phoenix.Socket.Socket Msg


initWebSocket : Phoenix.Socket.Socket msg
initWebSocket =
    Phoenix.Socket.init phoenixWSUrl



-- VIEWS


view : Model -> Html Msg
view model =
    -- div [ class "w3-container w3-center w3-padding-48" ]
    -- [
    div []
        [ viewLogo
        , p [] []
        , div []
            (case model.user of
                None ->
                    viewUserChoice

                CustomerUser ->
                    viewCustomer model.cargo

                HandlerUser ->
                    viewHandler model.handlingEventSource
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
        [ div [ class (colS4 "") ] [ p [] [] ]
        , div [ class (colS4 "w3-center w3-padding-48"), style [ ( "background-color", "#fee" ) ] ]
            [ button [ class (buttonClassStr "w3-margin"), onClick CustomerChosen ] [ text "Customers" ]
            , button [ class (buttonClassStr "w3-margin"), onClick HandlerChosen ] [ text "Handlers" ]
            ]
        , div [ class (colS4 "") ] [ p [] [] ]
        ]
    ]


viewCustomer : Cargo -> List (Html Msg)
viewCustomer cargo =
    case cargo.handlingEventList of
        Nothing ->
            [ div [ class row ]
                [ div [ class colS2 ]
                    [ p [] [] ]
                , div [ class (colS8 "") ]
                    [ div [ class "w3-bar" ]
                        [ input
                            [ class "w3-bar-item w3-border w3-round-large"
                            , style [ ( "width", "45em" ) ]
                            , type_ "text"
                            , placeholder "Tracking Number (e.g. ABC123, IJK456)"
                            , onInput TrackingIdEntered
                            ]
                            []
                        , button [ class (buttonClassStr "w3-bar-item w3-margin-left"), onClick FindTrackingId ] [ text "Track! " ]
                        ]
                    , div [ class colS2 ]
                        [ p [] [] ]
                    ]
                , p [] []
                ]
            ]

        Just handlingEvents ->
            [ div [ class row ]
                [ div [ class colS2 ] [ p [] [] ]
                , div [ class (colS8 "") ]
                    [ h2 [] [ text "Tracking Details" ]
                    , div [ class "w3-panel w3-padding-small w3-border w3-border-black w3-round-large" ]
                        [ div [ class "w3-panel w3-blue" ]
                            [ h5 [ class "w3-right" ] [ text "In Transit" ] ]
                        , div [ class "w3-panel" ]
                            [ div [ class "w3-left" ] [ text "Tracking Id:" ]
                            , div [ class "w3-right" ] [ text "Status:" ]
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
            ]


viewCustomerEventTable : HandlingEventList -> Html Msg
viewCustomerEventTable handlingEventList =
    table [ class "w3-table w3-striped w3-border w3-border-black" ]
        [ thead [ class "w3-pale-yellow" ]
            [ tr []
                [ th [] [ text "Voyage No" ]
                , th [] [ text "Location" ]
                , th [] [ text "Local Time" ]
                , th [] [ text "Type" ]
                ]
            ]
        , tbody []
            (List.map viewCustomerEvent handlingEventList.handling_events)
        ]


viewCustomerEvent : HandlingEvent -> Html Msg
viewCustomerEvent handlingEvent =
    tr []
        [ td [] [ text handlingEvent.voyage ]
        , td [] [ text handlingEvent.location ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlingEvent.completion_time) ]
        , td [] [ text handlingEvent.event_type ]
        ]


viewHandler : HandlingEventSource -> List (Html Msg)
viewHandler handlingEventSource =
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
    , div [ class row ]
        [ div [ class colS1 ] [ p [] [] ]
        , div [ class colS10 ] [ button [ class (buttonClassStr ""), onClick PutNewEvent ] [ text "New Handling Event" ] ]
        , div [ class colS1 ] [ p [] [] ]
        ]
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
    | HandlerChosen
    | TrackingIdEntered String
    | FindTrackingId
    | ReceivedHandlingEvents HandlingEventList
    | PutNewEvent
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | JoinedChannel String
    | HttpError String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOpMsg ->
            ( model, Cmd.none )

        Home ->
            let
                channel =
                    Phoenix.Channel.init "handling_event:*"
                        |> Phoenix.Channel.onJoin (always (JoinedChannel "handling_event:*"))

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model
                    | user = None
                    , cargo = initCargo
                    , handlingEventSource = initHandler
                    , phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        JoinedChannel channelName ->
            ( model, Cmd.none )

        CustomerChosen ->
            ( { model | user = CustomerUser }, Cmd.none )

        HandlerChosen ->
            -- ( { model | user = HandlerUser }, Cmd.none )
            ( { model | user = HandlerUser }, getAllHandlingEvents )

        TrackingIdEntered trackingId ->
            let
                newCargo =
                    (Cargo trackingId Nothing)
            in
                ( { model | cargo = newCargo }, Cmd.none )

        FindTrackingId ->
            ( model, getHandlingEvents (Just model.cargo.trackingId) )

        ReceivedHandlingEvents response ->
            let
                cargo =
                    model.cargo

                newCargo =
                    { cargo | handlingEventList = Just response }
            in
                ( { model | cargo = newCargo }, Cmd.none )

        PutNewEvent ->
            ( model, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

        HttpError errorString ->
            ( model, Cmd.none )



-- SERVER (PHOENIX APP) INTERFACE


phoenixHostPortUrl : String
phoenixHostPortUrl =
    "http://localhost:4000"


getHandlingEvents : Maybe String -> Cmd Msg
getHandlingEvents trackingId =
    case trackingId of
        Just id ->
            Http.send
                (\result ->
                    case result of
                        Ok response ->
                            ReceivedHandlingEvents response

                        Err httpErr ->
                            HttpError (toString httpErr)
                )
                (handlingEventsRequest id)

        Nothing ->
            getAllHandlingEvents


getAllHandlingEvents : Cmd Msg
getAllHandlingEvents =
    Http.send
        (\result ->
            case result of
                Ok response ->
                    ReceivedHandlingEvents response

                Err httpErr ->
                    HttpError (toString httpErr)
        )
        allHandlingEventsRequest


cargoesUrl : String
cargoesUrl =
    phoenixHostPortUrl ++ "/cargoes"


handlingEventsRequest : String -> Request HandlingEventList
handlingEventsRequest id =
    Http.get (cargoesUrl ++ "?_format=json&tracking_id=" ++ id) handlingEventListDecoder


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


handlingEventsUrl : String
handlingEventsUrl =
    phoenixHostPortUrl ++ "/events"


allHandlingEventsRequest : Request HandlingEventList
allHandlingEventsRequest =
    Http.get (handlingEventsUrl ++ "?_format=json") handlingEventListDecoder


handlingEventListDecoder : Decoder HandlingEventList
handlingEventListDecoder =
    decode HandlingEventList
        |> Pipeline.required "handling_events" (Json.Decode.list handlingEventDecoder)


handlingEventDecoder : Decoder HandlingEvent
handlingEventDecoder =
    decode HandlingEvent
        |> Pipeline.required "voyage" string
        |> Pipeline.required "type" string
        |> Pipeline.required "tracking_id" string
        |> Pipeline.required "registration_time" date
        |> Pipeline.required "completion_time" date
        |> Pipeline.required "location" string



-- SERVER (WEB SOCKET) INTERFACE


phoenixWSUrl : String
phoenixWSUrl =
    "ws:" ++ phoenixHostPortUrl ++ "/socket/websocket"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
