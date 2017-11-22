module Clerk exposing (Model, Msg(..), init, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)


-- Local Imports

import Shipping
import Styles exposing (..)


type alias Model =
    { trackingId : String
    , message : Maybe String
    , cargoResponse : Maybe Shipping.CargoResponse
    }


init : Model
init =
    (Model "" Nothing Nothing)


type Msg
    = TrackingIdEntered String
    | FindCargo


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TrackingIdEntered trackingId ->
            ( { model | trackingId = String.toUpper trackingId }, Cmd.none )

        FindCargo ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ viewHeader
        , viewMessage model
        , viewFindLine model
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
