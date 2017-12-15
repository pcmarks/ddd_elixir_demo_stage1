module App exposing (main)

import Html exposing (..)
import Html.Attributes exposing (class, id, type_, placeholder, style, src)
import Html.Events exposing (onClick)


{--
Local Inports
--}

import Clerk exposing (Model, initModel, view)
import ShippingOps exposing (Model, initModel, view)
import Styles exposing (..)


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
    | ShippingOpsUser


type alias Model =
    { user : User
    , clerkModel : Clerk.Model
    , shippingOpsModel : ShippingOps.Model
    }


init : Model
init =
    Model NoUser Clerk.initModel ShippingOps.initModel



-- MSG AND UPDATE


type Msg
    = BackToDemo
    | ClerkChosen
    | ClerkMsg Clerk.Msg
    | ShippingOpsChosen
    | ShippingOpsMsg ShippingOps.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BackToDemo ->
            ( { model
                | user = NoUser
                , clerkModel = Clerk.initModel
                , shippingOpsModel = ShippingOps.initModel
              }
            , Cmd.none
            )

        ClerkChosen ->
            ( { model | user = ClerkUser }, Cmd.none )

        ShippingOpsChosen ->
            ( { model | user = ShippingOpsUser }, Cmd.none )

        ClerkMsg clerkMsg ->
            let
                ( updatedClerkModel, clerkCmd ) =
                    (Clerk.update clerkMsg model.clerkModel)
            in
                ( { model | clerkModel = updatedClerkModel }, Cmd.map ClerkMsg clerkCmd )

        ShippingOpsMsg shippingOpsMsg ->
            let
                ( updatedShippingOpsModel, shippingOpsCmd ) =
                    (ShippingOps.update shippingOpsMsg model.shippingOpsModel)
            in
                ( { model | shippingOpsModel = updatedShippingOpsModel }, Cmd.map ShippingOpsMsg shippingOpsCmd )



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
                        , viewBackToDemo
                        ]

                ShippingOpsUser ->
                    div []
                        -- Tag any ShippingOps Msg's with type ShippingOpsMsg
                        [ Html.map ShippingOpsMsg (ShippingOps.view model.shippingOpsModel)
                        , viewBackToDemo
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
                    , onClick ShippingOpsChosen
                    ]
                    [ text "Shipping Ops Manager" ]
                ]
            , div [ class (colS4 "") ] [ p [] [] ]
            ]
        ]


viewBackToDemo : Html Msg
viewBackToDemo =
    div []
        [ p [] []
        , div [ class row ]
            [ div [ class (colS4 "") ]
                [ p [] []
                ]
            , div [ class (colS4 "w3-center") ]
                [ button
                    [ class (buttonClassStr "w3-center")
                    , onClick BackToDemo
                    ]
                    [ text "Back To Demo Home" ]
                ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
