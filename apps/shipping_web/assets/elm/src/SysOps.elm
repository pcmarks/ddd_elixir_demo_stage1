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
    Model "" Nothing Nothing


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ viewHeader
        , viewMessage model
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
