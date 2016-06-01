port module Ports exposing (..)

import Note exposing (..)
import Midi exposing (..)

port midiPort : MidiMessage -> Cmd msg

port masterVolumePort : Float -> Cmd msg
