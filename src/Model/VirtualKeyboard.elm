module Model.VirtualKeyboard exposing (VirtualKeyboardModel) -- where

import Note exposing (..)

type alias VirtualKeyboardModel =
  { octave   : Octave
  , velocity : Velocity
  }
