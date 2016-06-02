module Update exposing (..) -- where

import Msg exposing (..)
import Note exposing (..)
import Model.VirtualKeyboard as VirtualKbd exposing (..)
import Midi exposing (..)
import Ports exposing (..)
import Debug exposing (..)
import String exposing (..)
import Char exposing (..)

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
        midiNoteNumber =
          VirtualKbd.keyToMidiNoteNumber (symbol, (.octave model))
      in
        (addPressedNote model symbol, noteOnMessage midiNoteNumber (.velocity model) |> midiPort)


    KeyOff symbol ->
      let                
        midiNoteNumber =
          VirtualKbd.keyToMidiNoteNumber (getPressedKeyNote model symbol)
      in
        (removePressedNote model symbol, noteOffMessage midiNoteNumber (.velocity model) |> midiPort)


    MasterVolumeChange value ->
      (model, value |> masterVolumePort)


    OscillatorsBalanceChange value ->
      (model, value |> oscillatorsBalancePort)


    Oscillator1DetuneChange value ->
      (model, value |> oscillator1DetunePort)


    Oscillator2DetuneChange value ->
      (model, value |> oscillator2DetunePort)



