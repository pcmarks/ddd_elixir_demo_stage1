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
    { handlingEventList : Maybe HandlerEventList }


type alias HandlingEventList =
    { handling_events : List HandlingEvent }


type alias HandlingEvent =
    { event_type : String
    , completion_time : Date
    , voyage : String
    , location : String
    }


type alias HandlerEventList =
    { handling_events : List HandlerEvent }


type alias HandlerEvent =
    { voyage : String
    , event_type : String
    , tracking_id : String
    , registration_time : Date
    , completion_time : Date
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


row : Attribute msg
row =
    class "w3-row"


colS1 : Attribute msg
colS1 =
    class ("w3-col s1")


colS2 : Attribute msg
colS2 =
    class ("w3-col s2")


colS4 : String -> Attribute msg
colS4 classStr =
    class ("w3-col s4 " ++ classStr)


colS8 : String -> Attribute msg
colS8 classStr =
    class ("w3-col s8 " ++ classStr)


colS10 : Attribute msg
colS10 =
    class ("w3-col s10")


buttonClass : String -> Attribute msg
buttonClass classStr =
    class ("w3-button w3-round-large w3-deep-orange w3-border-orange w3-hover-border-navy " ++ classStr)



-- view


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
                    viewCustomer model

                HandlerUser ->
                    viewHandler model
            )
        ]


viewLogo : Html Msg
viewLogo =
    div [ row ]
        [ div [ colS4 "" ] [ p [] [] ]
        , div [ colS4 "w3-center" ]
            [ img [ src "images/ddd_logo.png", logoStyle, onClick Home ] []
            ]
        , div [ colS4 "" ] [ p [] [] ]
        , p [] []
        ]


viewUserChoice : List (Html Msg)
viewUserChoice =
    [ div [ row ]
        [ div [ colS4 "" ] [ p [] [] ]
        , div [ colS4 "w3-center w3-padding-48", style [ ( "background-color", "#fee" ) ] ]
            [ button [ buttonClass "", onClick CustomerChosen ] [ text "Customers" ]
            , button [ buttonClass "", onClick HandlerChosen ] [ text "Handlers" ]
            ]
        , div [ colS4 "" ] [ p [] [] ]
        ]
    ]


viewCustomer : Model -> List (Html Msg)
viewCustomer model =
    let
        customer =
            model.customer
    in
        case customer.handlingEventList of
            Nothing ->
                [ div [ row ]
                    [ div [ colS2 ]
                        [ p [] [] ]
                    , div [ colS8 "" ]
                        [ div [ class "w3-bar" ]
                            [ input
                                [ class "w3-bar-item w3-border w3-round-large"
                                , style [ ( "width", "30em" ) ]
                                , type_ "text"
                                , placeholder "Tracking Number (e.g. ABC123, IJK456)"
                                , onInput TrackingIdEntered
                                ]
                                []
                            , button [ buttonClass "w3-bar-item", onClick FindTrackingId ] [ text "Track! " ]
                            ]
                        , div [ colS2 ]
                            [ p [] [] ]
                        ]
                    , p [] []
                    ]
                ]

            Just handlingEvents ->
                [ div [ row ]
                    [ div [ colS2 ] [ p [] [] ]
                    , div [ colS8 "" ]
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
                    , div [ colS2 ] [ p [] [] ]
                    ]
                , div [ row ]
                    [ div [ colS2 ] [ p [] [] ]
                    , div [ colS8 "w3-padding-small", style [ ( "background-color", "#fee" ) ] ]
                        [ h5 [] [ text "Shipment Progress" ] ]
                    , div [ colS2 ] [ p [] [] ]
                    ]
                , div [ row ]
                    [ div [ colS2 ] [ p [] [] ]
                    , div [ colS8 "" ]
                        [ viewCustomerEventTable handlingEvents
                        ]
                    , div [ colS2 ] [ p [] [] ]
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


viewHandler : Model -> List (Html Msg)
viewHandler model =
    let
        handler =
            model.handler
    in
        [ div [ row ]
            [ div [ colS1 ] [ p [] [] ]
            , div [ colS10 ]
                [ h2 [] [ text "Handling Events List" ] ]
            , div [ colS1 ] [ p [] [] ]
            ]
        , case handler.handlingEventList of
            Nothing ->
                div [ row ]
                    [ div [ colS1 ] [ p [] [] ]
                    , div [ colS10 ]
                        [ h5 [] [ text "No Handling Events Available" ] ]
                    , div [ colS1 ] [ p [] [] ]
                    ]

            Just handlingEvents ->
                div [ row ]
                    [ div [ colS1 ] [ p [] [] ]
                    , div [ colS10 ] [ viewHandlerEventTable handlingEvents ]
                    , div [ colS1 ] [ p [] [] ]
                    ]
        ]


viewHandlerEventTable : HandlerEventList -> Html Msg
viewHandlerEventTable handlerEventList =
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
            (List.map viewHandlerEvent handlerEventList.handling_events)
        ]


viewHandlerEvent : HandlerEvent -> Html Msg
viewHandlerEvent handlerEvent =
    tr []
        [ td [] [ text handlerEvent.event_type ]
        , td [] [ text handlerEvent.location ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlerEvent.completion_time) ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlerEvent.registration_time) ]
        , td [] [ text handlerEvent.tracking_id ]
        , td [] [ text handlerEvent.voyage ]
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
    | ReceivedHandlerEvents HandlerEventList
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
            -- ( { model | user = HandlerUser }, Cmd.none )
            ( { model | user = HandlerUser }, fetchHandlerEvents )

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

        ReceivedHandlerEvents response ->
            let
                handler =
                    model.handler

                newHandler =
                    { handler | handlingEventList = Just response }
            in
                ( { model | handler = newHandler }, Cmd.none )

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


handlerEventsUrl : String
handlerEventsUrl =
    phoenixHostPortUrl ++ "/events"


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


fetchHandlerEvents : Cmd Msg
fetchHandlerEvents =
    Http.send
        (\result ->
            case result of
                Ok response ->
                    ReceivedHandlerEvents response

                Err httpErr ->
                    HttpError (toString httpErr)
        )
        handlerEventsRequest


handlerEventsRequest : Request HandlerEventList
handlerEventsRequest =
    Http.get (handlerEventsUrl ++ "?_format=json") handlerEventListDecoder


handlerEventListDecoder : Decoder HandlerEventList
handlerEventListDecoder =
    decode HandlerEventList
        |> Pipeline.required "handling_events" (Json.Decode.list handlerEventDecoder)


handlerEventDecoder : Decoder HandlerEvent
handlerEventDecoder =
    decode HandlerEvent
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
