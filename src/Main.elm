import Html exposing (Html, button, div, text, li, ul)
import Html.Attributes exposing (class)
import Html.App as Html
import Html.Events exposing (onClick)
import Keyboard exposing (..)
import Char exposing (..)
import Debug exposing (..)
import Ports exposing (..)
import Note exposing (..)
import Midi exposing (..)
import Model.VirtualKeyboard as VirtualKbd exposing (..)

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
handleKeyDown : VirtualKeyboardModel -> Keyboard.KeyCode -> Msg
handleKeyDown model keyCode =
  let
    symbol = keyCode |> Char.fromCode |> toLower
    allowedInput = List.member symbol VirtualKbd.allowedInputKeys
    isLastOctave = (.octave model) == 8
    unusedKeys = List.member symbol VirtualKbd.unusedKeysOnLastOctave
  in 
    if (not allowedInput) || (isLastOctave && unusedKeys) then
      NoOp
    else
      case symbol of
        'z' ->
          OctaveDown

        'x' ->
          OctaveUp

        'c' ->
          VelocityDown

        'v' ->
          VelocityUp

        symbol ->
          KeyOn symbol


handleKeyUp : VirtualKeyboardModel -> Keyboard.KeyCode -> Msg
handleKeyUp model keyCode =
  let
    symbol = keyCode |> Char.fromCode |> toLower
    pianoKeys = List.member symbol VirtualKbd.pianoKeys
    isLastOctave = (.octave model) == 8
    unusedKeys = List.member symbol VirtualKbd.unusedKeysOnLastOctave
  in 
    if (not pianoKeys) || (isLastOctave && unusedKeys) then
      NoOp
    else
      KeyOff symbol


subscriptions : VirtualKeyboardModel -> Sub Msg
subscriptions model =
  Sub.batch
    [ Keyboard.downs (handleKeyDown model)
    , Keyboard.ups (handleKeyUp model)
    ]
    
