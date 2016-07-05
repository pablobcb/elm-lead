module Component.Incrementer exposing (..)

import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html exposing (..)


type Incrementer
    = Octave
    | Patch
    | Velocity


incrementer : Incrementer -> String -> a -> a -> Html a
incrementer kind value up down =
    let
        displayClass =
            case kind of
                Velocity ->
                    "incrementer__display"

                Octave ->
                    "incrementer__display"

                Patch ->
                    "incrementer__display incrementer__display--patch"

        label' =
            toString kind
    in
        div [ class "incrementer" ]
            [ div [ class "incrementer__info" ]
                [ label [ class "incrementer__label" ] [ text label' ]
                , div [ class displayClass ] [ text value ]
                ]
            , div [ class "incrementer__buttons" ]
                [ button [ class "incrementer__button", onClick down ] []
                , button [ class "incrementer__button", onClick up ] []
                ]
            ]
