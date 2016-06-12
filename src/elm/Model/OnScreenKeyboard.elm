module Model.OnScreenKeyboard exposing (..) -- where

import Char exposing (..)
import Keyboard exposing (..)
import List exposing (..)
import Maybe.Extra exposing (..)

import Model.Note as Note exposing (..)
import Model.Midi as Midi exposing (..)


type alias PressedKey =
  (Char, MidiNote)

type alias OnScreenKeyBoard =
  { octave                     : Octave
  , velocity                   : Velocity
  , pressedNotes               : List PressedKey
  , clickedAndHovering         : Bool
  , mouseHoverNote             : Maybe MidiNote
  , mousePressedNote           : Maybe MidiNote
  , midiControllerPressedNotes : List MidiNote
  }

initOnScreenKeyboard : OnScreenKeyboard
initOnScreenKeyboard =
  { octave                     = 3
  , velocity                   = 100
  , pressedNotes               = []
  , clickedAndHovering         = False
  , mouseHoverNote             = Nothing
  , mousePressedNote           = Nothing
  , midiControllerPressedNotes = []
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

velocityDown : OnScreenKeyboard -> OnScreenKeyboard
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


velocityUp : OnScreenKeyboard -> OnScreenKeyboard
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

octaveDown : OnScreenKeyboard -> OnScreenKeyboard
octaveDown model =
  { model | octave = max (-2) ((.octave model) - 1) }

octaveUp : OnScreenKeyboard -> OnScreenKeyboard
octaveUp model =
  { model | octave = min 8 (model |> .octave |> (+) 1) }

mouseDown : OnScreenKeyboard -> OnScreenKeyboard
mouseDown model =
  { model | clickedAndHovering = True, mousePressedNote = model.mouseHoverNote }

mouseUp : OnScreenKeyboard -> OnScreenKeyboard
mouseUp model =
  { model | clickedAndHovering = False, mousePressedNote = Nothing }

mouseEnter : OnScreenKeyboard -> Int -> OnScreenKeyboard
mouseEnter model key =
  { model | mouseHoverNote = Just key, mousePressedNote = if model.clickedAndHovering then Just key else Nothing }

mouseLeave : OnScreenKeyboard -> Int -> OnScreenKeyboard
mouseLeave model key =
  { model | mouseHoverNote = Nothing, mousePressedNote = Nothing }

addClickedNote : OnScreenKeyboard -> MidiNote -> OnScreenKeyboard
addClickedNote model midiNote =
  { model | mousePressedNote = Just midiNote }


removeClickedNote : OnScreenKeyboard -> MidiNote -> OnScreenKeyboard
removeClickedNote model midiNote =
  { model | mousePressedNote = Just midiNote }


addPressedNote : OnScreenKeyboard -> Char -> OnScreenKeyboard
addPressedNote model symbol =
  { model | pressedNotes = (.pressedNotes model) ++ [ (symbol, keyToMidiNoteNumber (symbol, .octave model)) ] }


removePressedNote : OnScreenKeyboard -> Char -> OnScreenKeyboard
removePressedNote model symbol =
  { model | pressedNotes = List.filter (\(symbol', _) -> symbol /= symbol') model.pressedNotes }


findPressedKey : OnScreenKeyboard -> Char -> Maybe PressedKey
findPressedKey model symbol =
  List.head <| List.filter (\(symbol', _) -> symbol == symbol') model.pressedNotes


findPressedNote : OnScreenKeyboard -> MidiNote -> Maybe PressedKey
findPressedNote model midiNote =
  List.head <| List.filter (\(_, midiNote') -> midiNote == midiNote') model.pressedNotes

