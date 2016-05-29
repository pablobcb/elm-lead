port module MidiPort exposing (..)

import Note exposing (..)
import Midi exposing (..)

port noteOn : MidiMessage -> Cmd msg
