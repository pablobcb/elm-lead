module Model.VirtualKeyboard exposing (..) -- where

import Note exposing (..)
import Midi exposing (..)
import Msg exposing (..)
import Char exposing (..)
import Keyboard exposing (..)
import List exposing (..)
import Maybe.Extra exposing (..)

type alias PressedKey =
  (Char, MidiNote)

type alias VirtualKeyboardModel =
  { octave            : Octave
  , velocity          : Velocity
  , pressedNotes      : List PressedKey
  , mousePressed      : Bool
  , mouseHoverKey     : Maybe MidiNote
  , mousePressedKey   : Maybe MidiNote
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

keyToMidiNoteNumber : (Char, Octave) -> MidiNote
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

mouseDown : VirtualKeyboardModel -> VirtualKeyboardModel
mouseDown model =
  { model | mousePressed = True, mousePressedKey = model.mouseHoverKey }

mouseUp : VirtualKeyboardModel -> VirtualKeyboardModel
mouseUp model =
  { model | mousePressed = False, mousePressedKey = Nothing }

octaveDown : VirtualKeyboardModel -> VirtualKeyboardModel
octaveDown model =
  { model | octave = max (-2) ((.octave model) - 1) }

octaveUp : VirtualKeyboardModel -> VirtualKeyboardModel
octaveUp model =
  { model | octave = min 8 (model |> .octave |> (+) 1) }

mouseEnter : VirtualKeyboardModel -> Int -> VirtualKeyboardModel
mouseEnter model key =
  { model | mouseHoverKey = Just key, mousePressedKey = if model.mousePressed then Just key else Nothing }

mouseLeave : VirtualKeyboardModel -> Int -> VirtualKeyboardModel
mouseLeave model key =
  { model | mouseHoverKey = Nothing, mousePressedKey = Nothing }

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

    pressedNotes =
      findPressedNotes model symbol
  in 
    if invalidKey then
      NoOp
    else
      KeyOff symbol

addClickedNote : VirtualKeyboardModel -> MidiNote -> VirtualKeyboardModel
addClickedNote model midiNote =
  { model | mousePressedKey = Just midiNote }


removeClickedNote : VirtualKeyboardModel -> MidiNote -> VirtualKeyboardModel
removeClickedNote model midiNote =
  { model | mousePressedKey = Just midiNote }


addPressedNote : VirtualKeyboardModel -> Char -> VirtualKeyboardModel
addPressedNote model symbol =
  { model | pressedNotes = (.pressedNotes model) ++ [ (symbol, keyToMidiNoteNumber (symbol, .octave model)) ] }


removePressedNote : VirtualKeyboardModel -> Char -> VirtualKeyboardModel
removePressedNote model symbol =
  { model | pressedNotes = List.filter (\(symbol', _) -> symbol /= symbol') model.pressedNotes }


findPressedNotes : VirtualKeyboardModel -> Char -> List PressedKey
findPressedNotes model symbol =
  List.filter (\(symbol', _) -> symbol == symbol') model.pressedNotes


getPressedKeyNote: VirtualKeyboardModel -> Char -> PressedKey
getPressedKeyNote model midiNote =
  let
    firstPressedNote =
      List.head <| findPressedNotes model midiNote
  in
    case firstPressedNote of
      Just pressedNote ->
        pressedNote
      Nothing ->
        Debug.crash "Key up without key down first"
