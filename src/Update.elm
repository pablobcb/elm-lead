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
          VirtualKbd.keyToMidiNoteNumber symbol (.octave model)            
      in
        (addPressedKey model symbol, noteOnMessage midiNoteNumber (.velocity model) |> midiPort)


    KeyOff symbol ->
      let        
        pressedKey = 
          List.head <| List.filter (\(symbol', _) -> symbol == symbol') model.pressedKeys

        octave = 
          case pressedKey of
            Just pressedKey' ->
              snd pressedKey'
            Nothing ->
              Debug.crash "Key up without key down first"

        midiNoteNumber =
          VirtualKbd.keyToMidiNoteNumber symbol octave
      in
        (removePressedKey model symbol, noteOffMessage midiNoteNumber (.velocity model) |> midiPort)


    MasterVolumeChange value ->
      case String.toFloat value of
        Ok float -> 
          (model, float |> masterVolumePort)

        Err msg -> 
          Debug.crash msg
