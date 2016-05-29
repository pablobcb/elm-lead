port module MyPort exposing (..)

import Note exposing (..)
import MIDI exposing (..)

port noteOn : MidiMessage -> Cmd msg
