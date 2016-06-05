module View.Knob exposing (..) -- where

import Html exposing (..)
--import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Msg exposing (..)


knob : Float -> Float -> Float -> Html Msg
knob minimum maximum current =
  let
    -- These are defined in terms of degrees, with 0 pointing straight up
    visualMinimum = -140
    visualMaximum = 140
    visualRange = 280

    valueRange = (maximum - minimum)
    value = current / valueRange

    direction = visualMinimum + (value * visualRange)
    direction' = (toString direction) ++ "deg"
    knobStyle = "transform: rotate(" ++ direction' ++ ")"
  in
    div
      [ class "knob" ]
      [ div
        [ class "knob__inner"
        , attribute "style" knobStyle
        ]
        [ div [ class "knob__indicator" ] [ ] ]
      ]
