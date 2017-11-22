module Clerk exposing (Model, Msg(..), init, view)

import Html exposing (..)


type alias Model =
    Int


init : Model
init =
    42


type Msg
    = NoOp


view : Model -> Html Msg
view model =
    div [] []
