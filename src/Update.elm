module Update exposing (..) -- where

import Msg exposing (..)
import Note exposing (..)
import Model.VirtualKeyboard as VirtualKbd exposing (..)
import Midi exposing (..)
import Ports exposing (..)
import Debug exposing (..)
import String exposing (..)
import Char exposing (..)

noteOnCommand : Velocity -> Int -> Cmd msg
noteOnCommand velocity midiNoteNumber= 
  noteOnMessage midiNoteNumber velocity |> midiPort

noteOffCommand : Velocity -> Int -> Cmd msg
noteOffCommand velocity midiNoteNumber= 
  noteOffMessage midiNoteNumber velocity |> midiPort

update : Msg -> VirtualKeyboardModel -> (VirtualKeyboardModel, Cmd msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)


    MouseClickDown ->
      let
        model' = 
          mouseDown model
      in
        case .mouseHoverKey model of
          Just midiNoteNumber' ->
            (model', noteOnCommand (.velocity model') midiNoteNumber')
          Nothing ->
            (model', Cmd.none)

    MouseClickUp ->
      let
        model' = 
          mouseUp model
      in
        case .mouseHoverKey model of
          Just midiNoteNumber' ->
            (model', noteOffCommand (.velocity model') midiNoteNumber')
          Nothing ->
            (model', Cmd.none)

    MouseEnter midiNoteNumber ->
      let
        model' = 
          mouseEnter model midiNoteNumber
      in
        if .mousePressed model then
          (model', noteOnCommand (.velocity model') midiNoteNumber)
        else
          (model', Cmd.none)

    MouseLeave midiNoteNumber->
      let
        model' = 
          mouseLeave model midiNoteNumber
      in
        if .mousePressed model then
          (model', noteOffCommand (.velocity model') midiNoteNumber)
        else
          (model', Cmd.none)

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
        (addPressedNote model symbol, noteOnCommand (.velocity model) midiNoteNumber)


    KeyOff symbol ->
      let                
        midiNoteNumber =
          VirtualKbd.keyToMidiNoteNumber (getPressedKeyNote model symbol)
      in
        (removePressedNote model symbol, noteOffCommand (.velocity model) midiNoteNumber)


    MasterVolumeChange value ->
      (model, value |> masterVolumePort)


    OscillatorsBalanceChange value ->
      (model, value |> oscillatorsBalancePort)


    Oscillator1DetuneChange value ->
      (model, value |> oscillator1DetunePort)


    Oscillator2DetuneChange value ->
      (model, value |> oscillator2DetunePort)



