import Html exposing (Html, button, div, text, li, ul)
import Html.Attributes exposing (class)
import Html.App as Html
import Html.Events exposing (onClick)
import Debug exposing (..)
import Ports exposing (..)
import Note exposing (..)
import Midi exposing (..)
import Model.VirtualKeyboard as VirtualKbd exposing (..)
import Msg exposing (..)
import Keyboard exposing (..)
import Mouse exposing (..)

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
  , pressedNotes = []
  , mousePressed = False
  }
  Cmd.none


view : VirtualKeyboardModel -> Html Msg
view model =
  dashboard model


-- Subscriptions
subscriptions : VirtualKeyboardModel -> Sub Msg
subscriptions model =
  Sub.batch
    [ Keyboard.downs (VirtualKbd.handleKeyDown model)
    , Keyboard.ups (VirtualKbd.handleKeyUp model)
    --, Mouse.downs : (Position -> msg) -> Sub msg
    ]
    
