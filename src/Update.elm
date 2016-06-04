module Update exposing (..) -- where

import Msg exposing (..)
import Note exposing (..)
import Model.VirtualKeyboard as VirtualKbd exposing (..)
import Midi exposing (..)
import Ports exposing (..)
import Debug exposing (..)
import String exposing (..)
import Char exposing (..)
import Maybe.Extra exposing (..)

noteOnCommand : Velocity -> Int -> Cmd msg
noteOnCommand velocity midiNoteNumber= 
  noteOnMessage midiNoteNumber velocity |> midiPort

noteOffCommand : Velocity -> Int -> Cmd msg
noteOffCommand velocity midiNoteNumber= 
  noteOffMessage midiNoteNumber velocity |> midiPort

--f model midiNoteNumber = 
--  let
--    isKeyPressed midiNoteNumber = 
--      isJust <| findPressedNote model midiNoteNumber
--  
--    hoveringAndClickingKey = 
--      model.mousePressedNote
--    
--    model' = 
--      mouseUp model
--  in
--    case hoveringAndClickingKey of
--      Just midiNoteNumber ->
--        if isKeyPressed midiNoteNumber then
--          (model', Cmd.none)
--        else
--          (model', noteOffCommand (.velocity model') midiNoteNumber)
--      Nothing ->
--        (model', Cmd.none)
update : Msg -> VirtualKeyboardModel -> (VirtualKeyboardModel, Cmd msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    MouseClickDown ->
      let
        model' = 
          mouseDown model

        isKeyPressed midiNoteNumber = 
          isJust <| findPressedNote model' midiNoteNumber

        hoveringAndClickingKey = 
          model'.mousePressedNote
      in
        case hoveringAndClickingKey of
          Just midiNoteNumber-> 
            if isKeyPressed midiNoteNumber then
                (model', Cmd.none)
            else
              (model', noteOnCommand (.velocity model') midiNoteNumber)
          Nothing ->
            (model', Cmd.none)

    MouseClickUp ->
      let
        isKeyPressed midiNoteNumber = 
          isJust <| findPressedNote model midiNoteNumber

        hoveringAndClickingKey = 
          model.mousePressedNote
        
        model' = 
          mouseUp model
      in
        case hoveringAndClickingKey of
          Just midiNoteNumber ->
            if isKeyPressed midiNoteNumber then
              (model', Cmd.none)
            else
              (model', noteOffCommand (.velocity model') midiNoteNumber)
          Nothing ->
            (model', Cmd.none)

    MouseEnter midiNoteNumber ->
      let
        model' = 
          mouseEnter model midiNoteNumber

        isKeyPressed midiNoteNumber = 
          isJust <| findPressedNote model' midiNoteNumber

        hoveringAndClickingKey = 
          model'.mousePressedNote
      in
        case hoveringAndClickingKey of
          Just midiNoteNumber-> 
            if isKeyPressed midiNoteNumber then
              (model', Cmd.none)
            else
              (model', noteOnCommand (.velocity model') midiNoteNumber)
          Nothing ->
            (model', Cmd.none)

    MouseLeave midiNoteNumber->
      let
        isKeyPressed midiNoteNumber = 
          isJust <| findPressedNote model midiNoteNumber

        hoveringAndClickingKey =  
          model.mousePressedNote
        
        model' = 
          mouseLeave model midiNoteNumber
      in
        case hoveringAndClickingKey of
          Just midiNoteNumber ->
            if isKeyPressed midiNoteNumber then
              (model', Cmd.none)
            else
              (model', noteOffCommand (.velocity model') midiNoteNumber)
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
        model' =
          addPressedNote model symbol

        midiNoteNumber =
          VirtualKbd.keyToMidiNoteNumber (symbol, model.octave)

        hoveringAndClickingKey = 
          model.mousePressedNote
      in
        case hoveringAndClickingKey of
          Just midiNoteNumber' ->
            if midiNoteNumber == midiNoteNumber' then
              (model', Cmd.none)
            else
              (model', noteOnCommand (.velocity model) midiNoteNumber)
          Nothing ->
            (model', noteOnCommand (.velocity model) midiNoteNumber)


    KeyOff symbol ->
      let        
        releasedKey =
          findPressedKey model symbol

        hoveringAndClickingKey = 
          model.mousePressedNote

        model' =
          removePressedNote model symbol
      in
        case releasedKey of
          Just (symbol', midiNoteNumber) ->
            case hoveringAndClickingKey of
              Just midiNoteNumber' ->
                if midiNoteNumber == midiNoteNumber' then
                  (model', Cmd.none)
                else
                  (model', noteOffCommand model.velocity midiNoteNumber)
              Nothing ->
                (model', noteOffCommand model.velocity midiNoteNumber)
          Nothing ->
            (model', Cmd.none)


    MasterVolumeChange value ->
      (model, value |> masterVolumePort)


    OscillatorsBalanceChange value ->
      (model, value |> oscillatorsBalancePort)


    Oscillator1DetuneChange value ->
      (model, value |> oscillator1DetunePort)


    Oscillator2DetuneChange value ->
      (model, value |> oscillator2DetunePort)



