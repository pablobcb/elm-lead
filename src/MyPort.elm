port module MyPort exposing (..)

import Note exposing (..)
import MIDI exposing (..)

port noteOn : (Int, Velocity) -> Cmd msg