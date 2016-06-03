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

  let 
    breno = Debug.log ("msg: " ++ (toString msg) ++ " model:" ++ (toString model))
  in
  case msg of
    NoOp ->
      (model, Cmd.none)

    MouseClickDown ->
      let
        model' = 
          breno <| mouseDown model
      in
        case .mousePressedKey model' of
          Just midiNoteNumber' ->
            (model', noteOnCommand (.velocity model') midiNoteNumber')
          Nothing ->
            (model', Cmd.none)

    MouseClickUp ->
      let
        model' = 
          breno <| mouseUp model
      in
        case .mousePressedKey model of
          Just midiNoteNumber' ->
            (model', noteOffCommand (.velocity model') midiNoteNumber')
          Nothing ->
            (model', Cmd.none)

    MouseEnter midiNoteNumber ->
      let
        model' = 
          breno <| mouseEnter model midiNoteNumber
      in
        case .mousePressedKey model' of
          Just midiNoteNumber' ->
            (model', noteOnCommand (.velocity model') midiNoteNumber')
          Nothing ->
            (model', Cmd.none)

    MouseLeave midiNoteNumber->
      let
        model' = 
          breno <| mouseLeave model midiNoteNumber
      in
        case .mousePressedKey model of
          Just midiNoteNumber' ->
            (model', noteOffCommand (.velocity model') midiNoteNumber')
          Nothing ->
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
          VirtualKbd.keyToMidiNoteNumber (symbol, .octave model)
      in
        (addPressedNote model symbol, noteOnCommand (.velocity model) midiNoteNumber)


    KeyOff symbol ->
      let
        midiNoteNumber =
          Debug.log "midiNoteNumber:" <| snd <| getPressedKeyNote model symbol

        model' = 
          removePressedNote model <| Debug.log "Symbol:" symbol
      in
        if List.length (.pressedNotes model') > 1 then 
          (model', Cmd.none)
        else
          (model', noteOffCommand (.velocity model) midiNoteNumber)


    MasterVolumeChange value ->
      (model, value |> masterVolumePort)


    OscillatorsBalanceChange value ->
      (model, value |> oscillatorsBalancePort)


    Oscillator1DetuneChange value ->
      (model, value |> oscillator1DetunePort)


    Oscillator2DetuneChange value ->
      (model, value |> oscillator2DetunePort)



