module Clerk exposing (Model, Msg(..), init, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Date.Format


-- Local Imports

import Shipping
import Rest
import Styles exposing (..)


type alias Model =
    { trackingId : String
    , message : Maybe String
    , cargo : Maybe Shipping.Cargo
    }


init : Model
init =
    (Model "" Nothing Nothing)


type Msg
    = TrackingIdEntered String
    | FindCargo
    | RestMsg Rest.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TrackingIdEntered trackingId ->
            ( { model | trackingId = String.toUpper trackingId }, Cmd.none )

        FindCargo ->
            ( model, Cmd.map RestMsg (Rest.findCargo model.trackingId) )

        RestMsg restMsg ->
            case restMsg of
                Rest.ReceivedCargo response ->
                    case response of
                        Shipping.CargoNotFound serverMessage ->
                            ( { model
                                | message = Just serverMessage
                                , cargo = Nothing
                              }
                            , Cmd.none
                            )

                        Shipping.CargoFound cargo ->
                            ( { model
                                | message = Nothing
                                , cargo = Just cargo
                              }
                            , Cmd.none
                            )

                Rest.HttpError message ->
                    ( { model
                        | message = Just message
                        , cargo = Nothing
                      }
                    , Cmd.none
                    )


view : Model -> Html Msg
view model =
    div []
        [ viewHeader
        , viewMessage model
        , viewFindLine model
        , case model.cargo of
            Nothing ->
                div [] []

            Just cargo ->
                viewDetail cargo
        ]


viewHeader : Html Msg
viewHeader =
    div [ class row ]
        [ div [ class (colS3 "") ] [ p [] [] ]
        , div [ class (colS6 "w3-center") ]
            [ div []
                [ h1
                    [ class ""
                    , style [ ( "font", "bold" ), ( "color", "MidnightBlue" ) ]
                    ]
                    [ text "Shipping Clerk" ]
                ]
            ]
        ]


viewMessage : Model -> Html Msg
viewMessage model =
    case model.message of
        Just message ->
            div []
                [ div [ class row ]
                    [ div [ class (colS3 "") ] [ p [] [] ]
                    , div [ class (colS6 "w3-center") ]
                        [ h3 [] [ span [ class "w3-light-blue" ] [ text message ] ] ]
                    ]
                , div [] [ p [] [] ]
                ]

        Nothing ->
            div [] []


viewFindLine : Model -> Html Msg
viewFindLine model =
    div [ class row ]
        [ div [ class colS2 ]
            [ p [] [] ]
        , div [ class (colS8 "w3-center") ]
            [ div [ class "w3-bar" ]
                [ span
                    [ class "w3-bar-item"
                    , style [ ( "font", "bold" ), ( "color", "MidnightBlue" ) ]
                    ]
                    [ text "Enter a Tracking ID:" ]
                , input
                    [ class "w3-bar-item w3-border w3-round-large"

                    -- , style [ ( "width", "30em" ) ]
                    , id focusElement
                    , type_ "text"
                    , placeholder "e.g. ABC123, IJK456"
                    , onInput TrackingIdEntered
                    , value model.trackingId
                    ]
                    []
                , button [ class (buttonClassStr "w3-bar-item w3-margin-left"), onClick FindCargo ] [ text "Track! " ]
                ]
            ]
        , p [] []
        ]


viewDetail : Shipping.Cargo -> Html Msg
viewDetail cargo =
    div []
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
                [ case cargo.handlingEventsList of
                    Just listOfHandlingEvents ->
                        viewCustomerEventTable listOfHandlingEvents

                    Nothing ->
                        div [] []
                ]
            , div [ class colS2 ] [ p [] [] ]
            ]
        , p [] []
        ]


viewCustomerEventTable : List Shipping.HandlingEvent -> Html Msg
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


viewCustomerEvent : Shipping.HandlingEvent -> Html Msg
viewCustomerEvent handlingEvent =
    tr []
        -- [ td [] [ text handlingEvent.voyage ]
        [ td [] [ text handlingEvent.location ]
        , td [] [ text (Date.Format.format "%Y-%m-%d" handlingEvent.completion_time) ]
        , td [] [ text (Date.Format.format "%H:%M:%S" handlingEvent.completion_time) ]
        , td [] [ text handlingEvent.event_type ]
        ]
