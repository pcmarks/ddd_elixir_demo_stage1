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
    | ClerkUser


type alias HandlingEventSource =
    { newHandlingEvent : Maybe HandlingEvent
    , handlingEventList : Maybe HandlingEventList
    }


init : ( Model, Cmd msg )
init =
    ( Model None initCargo initClerk (initWebSocket), Cmd.none )


initClerk : HandlingEventSource
initClerk =
    (HandlingEventSource Nothing Nothing)



-- initWebSocket : Phoenix.Socket.Socket Msg


initWebSocket : Phoenix.Socket.Socket msg
initWebSocket =
    Phoenix.Socket.init phoenixWSUrl



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
                    viewCustomer model.cargo

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


viewCustomer : Cargo -> List (Html Msg)
viewCustomer cargo =
    viewCustomerHeader :: viewCustomerDetail cargo


viewCustomerHeader : Html Msg
viewCustomerHeader =
    div [ class row ]
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


viewCustomerDetail : Cargo -> List (Html Msg)
viewCustomerDetail cargo =
    case cargo.handlingEventList of
        Nothing ->
            [ div [ class row ]
                [ div [ class (colS3 "") ]
                    [ p [] [] ]
                , div [ class (colS6 "w3-center") ]
                    [ div [ class "w3-bar" ]
                        [ span
                            [ class "w3-bar-item"
                            , style [ ( "font", "bold" ), ( "color", "MidnightBlue" ) ]
                            ]
                            [ text "Enter your Tracking ID" ]
                        , input
                            [ class "w3-bar-item w3-border w3-round-large"

                            -- , style [ ( "width", "30em" ) ]
                            , type_ "text"
                            , placeholder "e.g. ABC123, IJK456"
                            , onInput TrackingIdEntered
                            ]
                            []
                        , button [ class (buttonClassStr "w3-bar-item w3-margin-left"), onClick FindTrackingId ] [ text "Track! " ]
                        ]

                    -- , div [ class colS2 ]
                    --     [ p [] [] ]
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
    | ClerkChosen
    | TrackingIdEntered String
    | FindTrackingId
    | ReceivedHandlingEvents HandlingEventList
    | ReceivedAllHandlingEvents HandlingEventList
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
                    , handlingEventSource = initClerk
                    , phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        JoinedChannel channelName ->
            ( model, Cmd.none )

        CustomerChosen ->
            ( { model | user = CustomerUser }, Cmd.none )

        ClerkChosen ->
            -- ( { model | user = ClerkUser }, Cmd.none )
            ( { model | user = ClerkUser }, getAllHandlingEvents )

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

        ReceivedAllHandlingEvents response ->
            let
                handlingEventSource =
                    model.handlingEventSource

                newHandlingEventSource =
                    HandlingEventSource Nothing (Just response)
            in
                ( { model | handlingEventSource = newHandlingEventSource }, Cmd.none )

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
                (customerCargoRequest id)

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


customerCargoRequest : String -> Request HandlingEventList
customerCargoRequest id =
    Http.get
        (customersUrl
            ++ "/cargoes"
            ++ "?_format=json&cargo_params[tracking_id]="
            ++ id
        )
        handlingEventListDecoder


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


clerkEventsUrl : String
clerkEventsUrl =
    phoenixHostPortUrl ++ clerksUrl ++ "/events"


allHandlingEventsRequest : Request HandlingEventList
allHandlingEventsRequest =
    Http.get (clerkEventsUrl ++ "?_format=json") handlingEventListDecoder


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
