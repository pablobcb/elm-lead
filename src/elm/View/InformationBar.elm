module View.InformationBar exposing (informationBar)

-- where

import Html exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (..)
import Model.Model exposing (Model)


informationBar : Model -> Html Msg
informationBar model =
    let
        startOctave =
            model |> .octave |> toString

        endOctave =
            model |> .octave |> (+) 1 |> toString

        octaveText =
            "Octave is C" ++ startOctave ++ " to C" ++ endOctave

        velocityText =
            ("Velocity is " ++ (model |> .velocity |> toString))
    in
        div [ class "information-bar" ]
            [ span [ class "information-bar__item" ] [ octaveText |> text ]
            , span [ class "information-bar__item" ] [ velocityText |> text ]
            ]
