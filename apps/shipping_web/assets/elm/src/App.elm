module App exposing (main)

import Html exposing (..)


-- MAIN Entry Point of Application


main =
    program
        { init = ( init, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type User
    = NoUser
    | ClerkUser
    | SysOpsUser


type alias Model =
    { user : User }


init : Model
init =
    Model NoUser



-- MSG AND UPDATE


type Msg
    = DemoHomeChosen
    | ClerkChosen
    | ClerkMsg
    | SysOpsChosen
    | SysOpsMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ text "App Page" ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
