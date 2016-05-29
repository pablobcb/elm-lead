module View.Dashboard exposing (..) -- where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)

import Model.VirtualKeyboard exposing (VirtualKeyboardModel)
import Update exposing (..)
import View.Keyboard exposing (keyboard)


dashboard : VirtualKeyboardModel -> Html Msg
dashboard model =
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
    div
      [ class "dashboard" ]
      [ div [] [ octaveText |> text ]
      , div [] [ velocityText |> text ]
      , keyboard
      ]
