port module Ports exposing (..)

import Model.Midi  exposing (..)
import Model.Model exposing (..)
import Model.Note  exposing (..)

port midiPort : MidiMessage -> Cmd msg

port noteInPort : (MidiNote -> msg) -> Sub msg

port masterVolumePort : Float -> Cmd msg

port oscillator1WaveformPort : String -> Cmd msg

port oscillator2WaveformPort : String -> Cmd msg

port oscillator2SemitonePort : Float -> Cmd msg

port oscillator2DetunePort : Float -> Cmd msg

port oscillatorsBalancePort : Float -> Cmd msg

port fmAmountPort : Float -> Cmd msg

port pulseWidthPort : Float -> Cmd msg

