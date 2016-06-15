module Component.NordButton exposing (..)

-- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.App exposing (map)
import Html.Attributes exposing (..)
import Lazy.List exposing (..)
import Maybe exposing (..)


-- MODEL


type alias Model a =
    { elems : List ( String, a )
    , currentElem : a
    , options : List ( String, a )
    }


init : List ( String, a ) -> Model a
init elems =
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
        }


type Msg
    = Click (String -> Cmd Msg)


btnStyle : List ( String, String )
btnStyle =
    [ ( "list-style-type", "none" ) ]


redStyle =
    [ ( "color", "red" ) ]



-- VIEW


view : (String -> Cmd Msg) -> Model a -> Html Msg
view cmdEmmiter model =
    div [ class "nord-btn" ]
        [ ul [] <| options model
        , button [ onClick <| Click cmdEmmiter ]
            [ text "a" ]
        ]


options model =
    List.map
        (\( label, elem ) ->
            option model elem label
        )
        model.options


option model elem label =
    let
        _ =
            Debug.log "model" model
    in
        li
            [ style
                <| if elem == model.currentElem then
                    redStyle
                   else
                    btnStyle
            ]
            [ text label ]


nordButton : (Msg -> b) -> (String -> Cmd Msg) -> Model c -> Html b
nordButton knobMsg cmdEmmiter model =
    Html.App.map knobMsg
        <| view (\value -> value |> cmdEmmiter)
            model



-- UPDATE


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
        Click cmdEmmiter ->
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
                    |> cmdEmmiter
                )
