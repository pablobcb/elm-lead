module Component.Incrementer exposing (incrementer)

import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html exposing (..)


incrementer : String -> String -> a -> a -> Html a
incrementer label' value up down =
    div [ class "incrementer" ]
        [ div [ class "incrementer__info" ]
            [ label [ class "incrementer__label" ] [ text label' ]
            , div [ class "incrementer__display" ] [ text value ]
            ]
        , div [ class "incrementer__buttons" ]
            [ button [ class "incrementer__button", onClick down ] []
            , button [ class "incrementer__button", onClick up ] []
            ]
        ]
