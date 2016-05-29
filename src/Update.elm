module Update exposing (..) -- where

import Note exposing (..)
import Model.VirtualKeyboard exposing (VirtualKeyboardModel)
import Midi exposing (..)
import MidiPort exposing (..)

-- Update
type Msg
  = NoOp
  | OctaveUp
  | OctaveDown
  | VelocityUp
  | VelocityDown
  | KeyOn Char
  --| NoteOn Note
  | NoteOff Note


update : Msg -> VirtualKeyboardModel -> (VirtualKeyboardModel, Cmd msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    OctaveDown ->
      (octaveDown model, Cmd.none)

    OctaveUp ->
      (octaveUp model, Cmd.none)

    VelocityDown ->
      (velocityDown model, Cmd.none)

    VelocityUp ->
      (velocityUp model,  Cmd.none)

    KeyOn symbol ->
      let
        velocity = .velocity model
        octave   = .octave model

        midiNoteNumber =
          noteToMidiNumber <|
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
              _ -> Debug.crash "shouldnt happen"
      in
        (model, makeMidiMessage midiNoteNumber model.velocity |> noteOn)


    NoteOff note->
      (model, Cmd.none)


--noteOn : NoteRepresentation -> Model
--noteOn {octave, velocity, note} =
--  Debug.log "AEEEEE"



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
