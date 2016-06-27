module Component.Switch exposing (..)

-- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.App exposing (map)
import Html.Attributes exposing (..)


type alias Model =
    { on : Bool
    , cmdEmitter : Bool -> Cmd Msg
    }


init : Bool -> (Bool -> Cmd Msg) -> Model
init on cmdEmitter =
    { on = on
    , cmdEmitter = cmdEmitter
    }


type Msg
    = Click


view : String -> Model -> Html Msg
view label model =
    let
        state =
            if model.on then
                "switch__item--active"
            else
                "switch__item--inactive"
    in
        div [ class "switch" ]
            [ div [ class "switch__item" ]
                [ div [ class state ] []
                , div [ class "switch__label" ]
                    [ text label ]
                ]
            , button [ class "switch__btn", onClick Click ] []
            ]


switch : String -> (Msg -> a) -> Model -> Html a
switch label switchMsg model =
    Html.App.map switchMsg
        <| view label model


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Click ->
            ( { model | on = not model.on }, model.cmdEmitter <| not model.on )
