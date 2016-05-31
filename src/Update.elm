module Update exposing (..) -- where

import Note exposing (..)
import Model.VirtualKeyboard as VirtualKbd exposing (..)
import Midi exposing (..)
import MidiPort exposing (..)
import Debug exposing (..)

-- Update
type Msg
  = NoOp
  | OctaveUp
  | OctaveDown
  | VelocityUp
  | VelocityDown
  | KeyOn Char
  | KeyOff Note


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
      if not <| List.member symbol VirtualKbd.allowedInputKeys then
          (model, Cmd.none)
      else
        let
          midiNoteNumber =
            VirtualKbd.keyToMidiNoteNumber symbol (.octave model)
       in
        (model, makeMidiMessage midiNoteNumber (.velocity model) |> noteOn)


    KeyOff symbol->
      (model, Cmd.none)