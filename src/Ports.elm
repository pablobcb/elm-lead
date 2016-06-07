port module Ports exposing (..)

import Note exposing (..)
import Midi exposing (..)

port midiPort : MidiMessage -> Cmd msg

port noteInPort : (MidiNote -> msg) -> Sub msg

port masterVolumePort : Float -> Cmd msg

port oscillator1DetunePort : Float -> Cmd msg

port oscillator2DetunePort : Float -> Cmd msg

port oscillatorsBalancePort : Float -> Cmd msg
