port module MidiPort exposing (..)

import Note exposing (..)
import Midi exposing (..)

port midiPort : MidiMessage -> Cmd msg
