module View.Knob exposing (..) -- where

import Html exposing (..)
--import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Msg exposing (..)


knob : Int -> Html Msg
knob direction =
  let
    direction' = (toString direction) ++ "deg"
    knobStyle = "transform: rotate(" ++ direction' ++ ")"
  in
    div
      [ class "knob" ]
      [ div
        [ class "knob__inner"
        , attribute "style" knobStyle
        ]
        [ div
          [ class "knob__indicator" ]
          [ ]
        ]
      ]
