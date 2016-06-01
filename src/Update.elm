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
  | KeyOff Char
  --| MasterVolumeChange Float


update : Msg -> VirtualKeyboardModel -> (VirtualKeyboardModel, Cmd msg)
update msg model =
  case msg of
    NoOp ->
      Debug.log "breno" (model, Cmd.none)


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
        midiNoteNumber =
          VirtualKbd.keyToMidiNoteNumber symbol (.octave model)
      in
        (model, noteOnMessage midiNoteNumber (.velocity model) |> midiPort)


    KeyOff symbol->
      let
        midiNoteNumber =
          VirtualKbd.keyToMidiNoteNumber symbol (.octave model)
      in
        (model, noteOffMessage midiNoteNumber (.velocity model) |> midiPort)
