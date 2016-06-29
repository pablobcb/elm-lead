module Component.OptionPicker exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.App exposing (map)
import Html.Attributes exposing (..)
import Lazy.List exposing (..)


type alias Model a =
    { elems : List ( String, a )
    , currentElem : a
    , options : List ( String, a )
    , cmdEmmiter : String -> Cmd Msg
    }


init : (String -> Cmd Msg) -> List ( String, a ) -> Model a
init cmdEmmiter elems =
    let
        current =
            snd
                <| case List.head elems of
                    Just elem ->
                        elem

                    Nothing ->
                        Debug.crash "empty list on button creation!"
    in
        { elems = elems
        , currentElem = current
        , options = elems
        , cmdEmmiter = cmdEmmiter
        }


type Msg
    = Click


view : String -> Model a -> Html Msg
view label model =
    div [ class "option-picker" ]
        [ span [ class "option-picker__label" ] [ text label ]
        , ul [ class "option-picker__list" ] <| options model
        , button [ class "option-picker__btn", onClick Click ]
            []
        ]


options : Model a -> List (Html b)
options model =
    List.map
        (\( label, elem ) ->
            option model elem label
        )
        model.options


option : Model a -> a -> String -> Html b
option model elem label =
    let
        state =
            if elem == model.currentElem then
                "option-picker__item--active"
            else
                "option-picker__item--inactive"
    in
        li [ class "option-picker__item" ]
            [ div [ class state ] []
            , div [ class "option-picker__item-id" ]
                [ text label ]
            ]


optionPicker : String -> (Msg -> b) -> Model c -> Html b
optionPicker label pickerMsg model =
    Html.App.map pickerMsg <| view label model


getNextElem : List ( String, a ) -> ( String, a )
getNextElem elems =
    let
        nextElem =
            case List.head elems of
                Just elem ->
                    elem

                Nothing ->
                    Debug.crash "no values provided"
    in
        nextElem


update : Msg -> Model a -> ( Model a, Cmd Msg )
update message model =
    case message of
        Click ->
            let
                elems =
                    Lazy.List.cycle <| Lazy.List.fromList model.elems

                elems' =
                    Lazy.List.toList
                        <| Lazy.List.take (List.length model.elems)
                        <| Lazy.List.drop 1 elems

                nextElem =
                    snd <| getNextElem elems'

                model' =
                    { model | elems = elems', currentElem = nextElem }
            in
                ( model'
                , nextElem
                    |> toString
                    |> model.cmdEmmiter
                )
