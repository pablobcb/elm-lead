module Model.VirtualKeyboard exposing (..) -- where

import Note exposing (..)
import Midi exposing (..)

type alias VirtualKeyboardModel =
  { octave   : Octave
  , velocity : Velocity
  }

allowedInputKeys: List Char
allowedInputKeys = 
  ['a','w','s','e','d'
  ,'f','t','g','y','h'
  ,'u','j','k','o','l','p'
  ]

keyToMidiNoteNumber : Char -> Octave -> Int
keyToMidiNoteNumber symbol octave =
  Midi.noteToMidiNumber <|
    case symbol of
      'a' -> ( C  , octave )
      'w' -> ( Db , octave )
      's' -> ( D  , octave )
      'e' -> ( Eb , octave )
      'd' -> ( E  , octave )
      'f' -> ( F  , octave )
      't' -> ( Gb , octave )
      'g' -> ( G  , octave )
      'y' -> ( Ab , octave )
      'h' -> ( A  , octave )
      'u' -> ( Bb , octave )
      'j' -> ( B  , octave )
      'k' -> ( C  , octave + 1 )
      'o' -> ( Db , octave + 1 )
      'l' -> ( D  , octave + 1 )
      'p' -> ( Eb , octave + 1 )
      _ -> Debug.crash "shouldnt happen"

velocityDown : VirtualKeyboardModel -> VirtualKeyboardModel
velocityDown model =
  let
    vel = .velocity model

  in
    { model | velocity =
      if vel < 40 then
        1
      else if vel == 127 then
        120
      else
        vel - 20
    }


velocityUp : VirtualKeyboardModel -> VirtualKeyboardModel
velocityUp model =
  let
    vel = .velocity model

  in
    { model | velocity =
      if vel == 1 then
        20
      else if vel >= 120 then
        127
      else
        vel + 20
    }


octaveDown : VirtualKeyboardModel -> VirtualKeyboardModel
octaveDown model =
  { model | octave = max (-2) ((.octave model) - 1) }


octaveUp : VirtualKeyboardModel -> VirtualKeyboardModel
octaveUp model =
  { model | octave = min 8 (model |> .octave |> (+) 1) }
