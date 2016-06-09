module Model.Model exposing (..) -- where

import Char exposing (..)
import Keyboard exposing (..)
import List exposing (..)
import Maybe.Extra exposing (..)

import Model.Note as Note exposing (..)
import Model.Midi as Midi exposing (..)


type alias PressedKey =
  (Char, MidiNote)

type OscillatorWaveform 
  = Sawtooth
  | Triangle
  | Sine
  | Square

type alias Model =
  { octave                     : Octave
  , velocity                   : Velocity
  , pressedNotes               : List PressedKey
  , clickedAndHovering         : Bool
  , mouseHoverNote             : Maybe MidiNote
  , mousePressedNote           : Maybe MidiNote
  , oscillator1Waveform        : OscillatorWaveform
  , oscillator2Waveform        : OscillatorWaveform
  , midiControllerPressedNotes : List MidiNote
  }

initModel : Model
initModel =
  { octave                     = 3
  , velocity                   = 100
  , pressedNotes               = []
  , clickedAndHovering         = False
  , mouseHoverNote             = Nothing
  , mousePressedNote           = Nothing
  , oscillator1Waveform        = Sawtooth
  , oscillator2Waveform        = Sawtooth
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

velocityDown : Model -> Model
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


velocityUp : Model -> Model
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

octaveDown : Model -> Model
octaveDown model =
  { model | octave = max (-2) ((.octave model) - 1) }

octaveUp : Model -> Model
octaveUp model =
  { model | octave = min 8 (model |> .octave |> (+) 1) }

mouseDown : Model -> Model
mouseDown model =
  { model | clickedAndHovering = True, mousePressedNote = model.mouseHoverNote }

mouseUp : Model -> Model
mouseUp model =
  { model | clickedAndHovering = False, mousePressedNote = Nothing }

mouseEnter : Model -> Int -> Model
mouseEnter model key =
  { model | mouseHoverNote = Just key, mousePressedNote = if model.clickedAndHovering then Just key else Nothing }

mouseLeave : Model -> Int -> Model
mouseLeave model key =
  { model | mouseHoverNote = Nothing, mousePressedNote = Nothing }

addClickedNote : Model -> MidiNote -> Model
addClickedNote model midiNote =
  { model | mousePressedNote = Just midiNote }


removeClickedNote : Model -> MidiNote -> Model
removeClickedNote model midiNote =
  { model | mousePressedNote = Just midiNote }


addPressedNote : Model -> Char -> Model
addPressedNote model symbol =
  { model | pressedNotes = (.pressedNotes model) ++ [ (symbol, keyToMidiNoteNumber (symbol, .octave model)) ] }


removePressedNote : Model -> Char -> Model
removePressedNote model symbol =
  { model | pressedNotes = List.filter (\(symbol', _) -> symbol /= symbol') model.pressedNotes }


findPressedKey : Model -> Char -> Maybe PressedKey
findPressedKey model symbol =
  List.head <| List.filter (\(symbol', _) -> symbol == symbol') model.pressedNotes


findPressedNote : Model -> MidiNote -> Maybe PressedKey
findPressedNote model midiNote =
  List.head <| List.filter (\(_, midiNote') -> midiNote == midiNote') model.pressedNotes

setOscillator1Waveform : Model -> OscillatorWaveform -> Model
setOscillator1Waveform model waveform =
  { model | oscillator1Waveform = waveform }

setOscillator2Waveform : Model -> OscillatorWaveform -> Model
setOscillator2Waveform model waveform =
  { model | oscillator2Waveform = waveform }
