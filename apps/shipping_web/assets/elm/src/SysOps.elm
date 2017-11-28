module SysOps exposing (Model, Msg(..), init, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Date.Format


-- Local Imports

import Shipping
import Rest
import Styles exposing (..)


type alias Model =
    { searchCriteria : String
    , message : Maybe String
    , handlingEventList : Maybe Shipping.HandlingEventList
    }


init : Model
init =
    Model "All" Nothing Nothing


type Msg
    = SearchHandlingEvents
    | RestMsg Rest.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchHandlingEvents ->
            ( model, Cmd.map RestMsg (Rest.getAllHandlingEvents) )

        RestMsg restMsg ->
            case restMsg of
                Rest.ReceivedAllHandlingEvents handlingEventList ->
                    ( { model
                        | message = Nothing
                        , handlingEventList = Just handlingEventList
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ viewHeader
        , viewMessage model
        , viewSearchLine model
        , viewDetail model.handlingEventList
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
                    [ text "Systems Operation Manager" ]
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


viewSearchLine : Model -> Html Msg
viewSearchLine model =
    div [ class row ]
        [ div [ class colS2 ]
            [ p [] [] ]
        , div [ class (colS8 "w3-center") ]
            [ div [ class "w3-bar" ]
                [ span
                    [ class "w3-bar-item"
                    , style [ ( "color", "MidnightBlue" ) ]
                    ]
                    [ text "Specify Search Criteria: " ]
                , span
                    [ class "w3-bar-item"
                    , style [ ( "font-weight", "bold" ), ( "color", "MidnightBlue" ) ]
                    ]
                    [ text (model.searchCriteria) ]
                , button
                    [ class (buttonClassStr "w3-bar-item w3-margin-left")
                    , onClick SearchHandlingEvents
                    ]
                    [ text "Search! " ]
                ]
            , p [] []
            ]
        ]


viewDetail : Maybe Shipping.HandlingEventList -> Html Msg
viewDetail maybeHandlingEventList =
    div []
        [ div [ class row ]
            [ div [ class colS1 ] [ p [] [] ]
            , div [ class colS10 ]
                [ h2 [] [ text "Handling Events List" ] ]
            , div [ class colS1 ] [ p [] [] ]
            ]
        , case maybeHandlingEventList of
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


viewHandlingEventTable : Shipping.HandlingEventList -> Html Msg
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


viewHandlingEvent : Shipping.HandlingEvent -> Html Msg
viewHandlingEvent handlingEvent =
    tr []
        [ td [] [ text handlingEvent.event_type ]
        , td [] [ text handlingEvent.location ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlingEvent.completion_time) ]
        , td [] [ text (Date.Format.format "%Y-%m-%d %H:%M:%S" handlingEvent.registration_time) ]
        , td [] [ text handlingEvent.tracking_id ]
        , td [] [ text handlingEvent.voyage ]
        ]
