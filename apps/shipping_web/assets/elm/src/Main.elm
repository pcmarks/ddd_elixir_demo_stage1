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
    , customer : Customer
    , handler : Handler
    , phxSocket : Phoenix.Socket.Socket Msg
    }


type User
    = None
    | CustomerUser
    | HandlerUser


type alias Customer =
    { trackingId : Maybe String
    , handlingEventList : Maybe HandlingEventList
    }


type alias Handler =
    { handlingEventList : Maybe HandlingEventList }


type alias HandlingEventList =
    { handling_events : List HandlingEvent }


type alias HandlingEvent =
    { event_type : String
    , completion_time : Date
    , voyage : String
    , location : String
    }


init : ( Model, Cmd msg )
init =
    ( Model None initCustomer initHandler (initWebSocket), Cmd.none )


initCustomer : Customer
initCustomer =
    (Customer Nothing Nothing)


initHandler : Handler
initHandler =
    (Handler Nothing)



-- initWebSocket : Phoenix.Socket.Socket Msg


initWebSocket : Phoenix.Socket.Socket msg
initWebSocket =
    Phoenix.Socket.init phoenixWSUrl



-- VIEWS
--- Styles


logoStyle : Attribute msg
logoStyle =
    style [ ( "display", "inline-block" ), ( "width", "257px" ), ( "height", "88px" ), ( "background-size", " 257px 88px" ) ]


trackingStyle : Attribute Msg
trackingStyle =
    style [ ( "background-color", "#eee" ), ( "padding-left", "48px" ), ( "padding-right", "48px" ) ]


controlClass : String -> String
controlClass control =
    control ++ " w3-bar-item w3-border w3-border-orange w3-hover-border-navy w3-round-large  w3-margin-right w3-deep-orange"



-- view


view : Model -> Html Msg
view model =
    div [ class "w3-container w3-center w3-padding-48" ]
        [ viewLogo
        , p [] []
        , case model.user of
            None ->
                viewUserChoice

            CustomerUser ->
                viewCustomer model

            HandlerUser ->
                viewHandler model
        ]


viewLogo : Html Msg
viewLogo =
    div [ class "w3-bar  w3-border-bottom" ]
        [ img [ class "w3-bar-item w3-left", src "images/ddd_logo.png", logoStyle, onClick Home ] [] ]


viewUserChoice : Html Msg
viewUserChoice =
    div [ class "w3-bar w3-center w3-padding-48", trackingStyle ]
        [ button [ class (controlClass "w3-button"), onClick CustomerChosen ] [ text "Customer" ]
        , button [ class (controlClass "w3-button"), onClick HandlerChosen ] [ text "Handler" ]
        ]


viewCustomer : Model -> Html Msg
viewCustomer model =
    let
        customer =
            model.customer
    in
        case customer.handlingEventList of
            Nothing ->
                div [ class "w3-bar w3-center w3-padding-48", trackingStyle ]
                    [ input
                        [ class "w3-bar-item"
                        , style [ ( "width", "30em" ) ]
                        , type_ "text"
                        , placeholder "Tracking Number (e.g. ABC123, IJK456)"
                        , onInput TrackingIdEntered
                        ]
                        []
                    , button [ class "w3-bar-item w3-button w3-round-large w3-margin-left w3-deep-orange", onClick FindTrackingId ] [ text "Track! " ]
                    ]

            Just handlingEvents ->
                div [ class "w3-row" ]
                    [ div [ class "w3-col m3" ] [ p [] [] ]
                    , div [ class "w3-col m6" ]
                        [ viewHandlingEventTable
                            handlingEvents
                        ]
                    , div [ class "3-col m3" ] [ p [] [] ]
                    ]


viewHandlingEventTable : HandlingEventList -> Html Msg
viewHandlingEventTable handlingEventList =
    table [ class "w3-table w3-striped w3-border" ]
        [ thead []
            [ tr []
                [ th [] [ text "Voyage No" ]
                , th [] [ text "Location" ]
                , th [] [ text "Local Time" ]
                , th [] [ text "Type" ]
                ]
            ]
        , tbody []
            (List.map viewHandlingEvent handlingEventList.handling_events)
        ]


viewHandlingEvent : HandlingEvent -> Html Msg
viewHandlingEvent handlingEvent =
    tr []
        [ td [] [ text handlingEvent.voyage ]
        , td [] [ text handlingEvent.location ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlingEvent.completion_time) ]
        , td [] [ text handlingEvent.event_type ]
        ]


viewHandler : Model -> Html Msg
viewHandler model =
    div [] [ text "HANDLER STUFF" ]



-- MSG AND UPDATE


type Msg
    = NoOpMsg
    | Home
    | CustomerChosen
    | HandlerChosen
    | TrackingIdEntered String
    | FindTrackingId
    | ReceivedHandlingEvents HandlingEventList
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
                    , customer = initCustomer
                    , handler = initHandler
                    , phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        JoinedChannel channelName ->
            ( model, Cmd.none )

        CustomerChosen ->
            ( { model | user = CustomerUser }, Cmd.none )

        HandlerChosen ->
            ( { model | user = HandlerUser }, Cmd.none )

        TrackingIdEntered trackingId ->
            let
                customer =
                    model.customer

                newCustomer =
                    { customer | trackingId = Just trackingId, handlingEventList = Nothing }
            in
                ( { model | customer = newCustomer }, Cmd.none )

        FindTrackingId ->
            ( model, fetchCustomerTrackingId model.customer.trackingId )

        ReceivedHandlingEvents response ->
            let
                customer =
                    model.customer

                newCustomer =
                    { customer | handlingEventList = Just response }
            in
                ( { model | customer = newCustomer }, Cmd.none )

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


fetchCustomerTrackingId : Maybe String -> Cmd Msg
fetchCustomerTrackingId trackingId =
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
                (trackingIdRequest id)

        Nothing ->
            Cmd.none


cargoesUrl : String
cargoesUrl =
    phoenixHostPortUrl ++ "/cargoes"


trackingIdRequest : String -> Request HandlingEventList
trackingIdRequest id =
    Http.get (cargoesUrl ++ "?_format=json&tracking_id=" ++ id) handlingEventListDecoder


handlingEventListDecoder : Decoder HandlingEventList
handlingEventListDecoder =
    decode HandlingEventList
        |> Pipeline.required "handling_events" (Json.Decode.list handlingEventDecoder)


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


handlingEventDecoder : Decoder HandlingEvent
handlingEventDecoder =
    decode HandlingEvent
        |> Pipeline.required "type" string
        |> Pipeline.required "completion_time" date
        |> Pipeline.required "voyage" string
        |> Pipeline.required "location" string



-- SERVER (WEB SOCKET) INTERFACE


phoenixWSUrl : String
phoenixWSUrl =
    "ws:" ++ phoenixHostPortUrl ++ "/socket/websocket"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
