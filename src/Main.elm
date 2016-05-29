import Html exposing (Html, button, div, text, li, ul)
import Html.Attributes exposing (class)
import Html.App as Html
import Html.Events exposing (onClick)
import Keyboard exposing (..)
import Debug exposing (..)
import Char exposing (..)
import MidiPort exposing (..)
import Note exposing (..)
import Midi exposing (..)
import Model.VirtualKeyboard exposing (VirtualKeyboardModel)

import Update exposing (..)
import View.Dashboard exposing (..)

main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


init : (VirtualKeyboardModel, Cmd msg)
init =
  (,)
  { octave   = 3
  , velocity = 100
  }
  Cmd.none


view : VirtualKeyboardModel -> Html Msg
view model =
  dashboard model

-- Subscriptions
handleKey : Keyboard.KeyCode -> Msg
handleKey keyCode =
  case keyCode |> Char.fromCode |> toLower of
  -- Keyboard Controls
    'z' ->
      OctaveDown

    'x' ->
      OctaveUp

    'c' ->
      VelocityDown

    'v' ->
      VelocityUp

  -- Notes
    symbol ->
      KeyOn symbol


subscriptions : VirtualKeyboardModel -> Sub Msg
subscriptions model =
  Keyboard.presses handleKey
