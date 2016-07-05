module Component.Incrementer exposing (incrementer)

import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html exposing (..)


incrementer : String -> String -> a -> a -> Html a
incrementer label value up down =
    div [ class "incrementer" ]
        [ div [ class "incrementer__label" ] [ text label ]
        , button
            [ class "incrementer__btn"
            , onClick down
            ]
            []
        , span [ class "incrementer__label" ] [ text "-" ]
        , div [ class "incrementer__display" ] [ text ("." ++ value) ]
        , span [ class "incrementer__label" ]
            [ text "+" ]
        , button
            [ class "incrementer__btn"
            , onClick up
            ]
            []
        ]
