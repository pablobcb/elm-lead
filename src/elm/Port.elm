port module Port exposing (..)

import Midi exposing (..)


port midiOutPort : MidiMessage -> Cmd msg


port midiInPort : (MidiMessage -> msg) -> Sub msg


port masterVolumePort : Int -> Cmd msg


port oscillator1WaveformPort : String -> Cmd msg


port oscillator2WaveformPort : String -> Cmd msg


port oscillator2SemitonePort : Int -> Cmd msg


port oscillator2DetunePort : Int -> Cmd msg


port oscillatorsBalancePort : Int -> Cmd msg


port fmAmountPort : Int -> Cmd msg


port pulseWidthPort : Int -> Cmd msg
