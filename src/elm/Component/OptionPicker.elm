module Component.OptionPicker
    exposing
        ( optionPicker
        , update
        , Model
        , init
        , Msg(..)
        )

import Html exposing (Html, div, span, ul, li, button, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.App
import Lazy.List as Lazy


type alias Model a =
    { elems : List ( String, a )
    , currentElem : a
    , options : List ( String, a )
    , cmdEmmiter : String -> Cmd Msg
    }


init : (String -> Cmd Msg) -> a -> List ( String, a ) -> Model a
init cmdEmmiter selected elems =
    let
        orderedElems =
            elems
                |> Lazy.fromList
                |> Lazy.cycle
                |> Lazy.dropWhile (\( _, elem ) -> elem /= selected)
                |> Lazy.take (List.length elems)
                |> Lazy.toList

        selectedElem =
            snd
                <| case List.head orderedElems of
                    Just elem ->
                        elem

                    Nothing ->
                        Debug.crash "empty list on button creation!"
    in
        { currentElem = selectedElem
        , options = elems
        , cmdEmmiter = cmdEmmiter
        , elems = orderedElems
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
option model elem name =
    let
        state =
            if elem == model.currentElem then
                "option-picker__item--active"
            else
                "option-picker__item--inactive"
    in
        li [ class "option-picker__item" ]
            [ div [ class state ] []
            , div [ class <| "option-picker__id--" ++ name ] []
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
                    Lazy.cycle <| Lazy.fromList model.elems

                elems' =
                    Lazy.toList
                        <| Lazy.take (List.length model.elems)
                        <| Lazy.drop 1 elems

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
