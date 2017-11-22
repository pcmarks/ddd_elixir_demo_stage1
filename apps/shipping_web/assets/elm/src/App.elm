module App exposing (main)

import Html exposing (..)
import Html.Attributes exposing (class, id, type_, placeholder, style, src)
import Html.Events exposing (onClick)


{--
Local Inports
--}

import Clerk exposing (Model, init, view)
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
    | ClerkUser Clerk.Model
    | SysOpsUser


type alias Model =
    { user : User }


init : Model
init =
    Model NoUser



-- MSG AND UPDATE


type Msg
    = BackToDemo
    | ClerkChosen
    | ClerkMsg Clerk.Msg
    | SysOpsChosen
    | SysOpsMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BackToDemo ->
            ( { model | user = NoUser }, Cmd.none )

        ClerkChosen ->
            ( { model | user = ClerkUser Clerk.init }, Cmd.none )

        _ ->
            ( model, Cmd.none )



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

                ClerkUser clerkModel ->
                    div []
                        [ Html.map ClerkMsg (Clerk.view clerkModel)
                        , viewBackToDemo
                        ]

                -- Clerk.view model.user
                SysOpsUser ->
                    div []
                        [ text "SYSOPS"
                        , viewBackToDemo
                        ]

            -- SysOps.view model.user
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
                    , onClick SysOpsChosen
                    ]
                    [ text "Sys Ops Manager" ]
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
                    [ text "Back" ]
                ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
