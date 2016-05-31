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
handleKeyDown : Keyboard.KeyCode -> Msg
handleKeyDown keyCode =
  let
    symbol = keyCode |> Char.fromCode |> toLower
    allowedInput = List.member symbol VirtualKbd.allowedInputKeys
  in 
    if not allowedInput then
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


handleKeyUp : Keyboard.KeyCode -> Msg
handleKeyUp keyCode =
  let
    symbol = keyCode |> Char.fromCode |> toLower
    pianoKeys = List.member symbol VirtualKbd.pianoKeys
  in 
    if not pianoKeys then
      NoOp
    else
      KeyOff symbol


subscriptions : VirtualKeyboardModel -> Sub Msg
subscriptions model =
  Sub.batch
    [ Keyboard.downs handleKeyDown
    , Keyboard.ups (\ keyCode -> Debug.log "BRENO" NoOp)
    ]
    
