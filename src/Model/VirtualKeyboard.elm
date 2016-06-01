module Model.VirtualKeyboard exposing (..) -- where

import Note exposing (..)
import Midi exposing (..)
import Msg exposing (..)
import Char exposing (..)
import Keyboard exposing (..)
import List exposing (..)

type alias PressedNote =
  (Char, Octave)

type alias VirtualKeyboardModel =
  { octave       : Octave
  , velocity     : Velocity
  , pressedNotes : List PressedNote
  }

pianoKeys: List Char
pianoKeys = 
  ['a', 'w', 's', 'e', 'd'
  ,'f', 't', 'g', 'y', 'h'
  ,'u', 'j', 'k', 'o', 'l', 'p'
  ]

allowedInputKeys: List Char
allowedInputKeys = 
  ['z', 'c', 'x', 'v'] ++ pianoKeys

unusedKeysOnLastOctave: List Char
unusedKeysOnLastOctave =
  ['h','u', 'j', 'k', 'o', 'l', 'p']

keyToMidiNoteNumber : PressedNote -> Int
keyToMidiNoteNumber (symbol, octave) =
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
      _ -> Debug.crash ("Note and octave outside MIDI bounds: " ++ toString symbol ++ " " ++ toString octave)

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


handleKeyDown : VirtualKeyboardModel -> Keyboard.KeyCode -> Msg
handleKeyDown model keyCode =
  let
    symbol = 
      keyCode |> Char.fromCode |> toLower 

    allowedInput = 
      List.member symbol allowedInputKeys

    isLastOctave = 
      (.octave model) == 8

    unusedKeys = 
      List.member symbol unusedKeysOnLastOctave   
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
    symbol = 
      keyCode |> Char.fromCode |> toLower

    invalidKey = 
      not <| List.member symbol pianoKeys

    hasPressedNotes =
      List.isEmpty <| List.filter (\(symbol', _) -> symbol == symbol') (.pressedNotes model)
  in 
    if invalidKey || hasPressedNotes then
      NoOp
    else
      KeyOff symbol


addPressedNote : VirtualKeyboardModel -> Char -> VirtualKeyboardModel
addPressedNote model symbol =
  { model | pressedNotes = (.pressedNotes model) ++ [(symbol, (.octave model))] }


removePressedNote : VirtualKeyboardModel -> Char -> VirtualKeyboardModel
removePressedNote model symbol =
  { model | pressedNotes = List.filter (\(symbol', octave') -> symbol /= symbol') model.pressedNotes }


findFirstPressedNote : VirtualKeyboardModel -> Char -> Maybe PressedNote
findFirstPressedNote model symbol =
  List.head <| List.filter (\(symbol', _) -> symbol == symbol') model.pressedNotes


getPressedKeyNote: VirtualKeyboardModel -> Char -> PressedNote
getPressedKeyNote model symbol =
  let
    firstPressedNote =
      findFirstPressedNote model symbol
  in
    case firstPressedNote of
      Just pressedNote ->
        pressedNote
      Nothing ->
        Debug.crash "Key up without key down first"
