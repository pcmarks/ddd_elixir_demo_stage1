module Tracking exposing (..)

{--
The Tracking module represents the Application that allows Clerks and Shipping
Operations Managers to show the status of a particular cargo or the a listing
of all the Handling Events in the system, respectively.

Control/Messages are handled by dispatching "down" to the Clerk or OpsManager
modules.

--}

import Html exposing (..)
import Html.Attributes exposing (class, id, type_, placeholder, style, src)
import Html.Events exposing (onClick)


{--
Local Inports
--}

import Clerk exposing (Model, initModel, view)
import OpsManager exposing (Model, initModel, view)
import Styles exposing (..)


-- MAIN Entry Point of Application


main =
    program
        { init = ( initModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type User
    = NoUser
    | ClerkUser
    | OpsManagerUser


type alias Model =
    { user : User
    , clerkModel : Clerk.Model
    , shippingOpsModel : OpsManager.Model
    }


initModel : Model
initModel =
    Model NoUser Clerk.initModel OpsManager.initModel



-- MSG AND UPDATE


type Msg
    = BackToDemo
    | ClerkChosen
    | ClerkMsg Clerk.Msg
    | OpsManagerChosen
    | OpsManagerMsg OpsManager.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BackToDemo ->
            ( { model
                | user = NoUser
                , clerkModel = Clerk.initModel
                , shippingOpsModel = OpsManager.initModel
              }
            , Cmd.none
            )

        ClerkChosen ->
            ( { model | user = ClerkUser }, Cmd.none )

        OpsManagerChosen ->
            ( { model | user = OpsManagerUser }, Cmd.none )

        ClerkMsg clerkMsg ->
            let
                ( updatedClerkModel, clerkCmd ) =
                    (Clerk.update clerkMsg model.clerkModel)
            in
                ( { model | clerkModel = updatedClerkModel }, Cmd.map ClerkMsg clerkCmd )

        OpsManagerMsg shippingOpsMsg ->
            let
                ( updatedOpsManagerModel, shippingOpsCmd ) =
                    (OpsManager.update shippingOpsMsg model.shippingOpsModel)
            in
                ( { model | shippingOpsModel = updatedOpsManagerModel }, Cmd.map OpsManagerMsg shippingOpsCmd )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewLogo
        , p [] []
        , div []
            [ case model.user of
                NoUser ->
                    viewUserChoice

                ClerkUser ->
                    div []
                        -- Tag any Clerk Msg's with type ClerkMsg
                        [ Html.map ClerkMsg (Clerk.view model.clerkModel)
                        ]

                OpsManagerUser ->
                    div []
                        -- Tag any OpsManager Msg's with type OpsManagerMsg
                        [ Html.map OpsManagerMsg (OpsManager.view model.shippingOpsModel)
                        ]
            ]
        ]


viewLogo : Html Msg
viewLogo =
    div [ class row ]
        [ div [ class (colS4 "") ] [ p [] [] ]
        , div [ class (colS4 "w3-center") ]
            [ img
                [ src "images/ddd_logo.png"
                , style logo
                , onClick BackToDemo
                ]
                []
            ]
        , div [ class (colS4 "") ] [ p [] [] ]
        , p [] []
        ]


viewUserChoice : Html Msg
viewUserChoice =
    div []
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
            , div
                [ class (colS4 "w3-center w3-padding-48")
                , style [ ( "background-color", "#fee" ) ]
                ]
                [ button
                    [ class (buttonClassStr "w3-margin")
                    , onClick ClerkChosen
                    ]
                    [ text "Clerk" ]
                , button
                    [ class (buttonClassStr "w3-margin")
                    , onClick OpsManagerChosen
                    ]
                    [ text "Shipping Ops Manager" ]
                ]
            , div [ class (colS4 "") ] [ p [] [] ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
