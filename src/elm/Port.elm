port module Port exposing (..)

import Midi exposing (..)


port midiOutPort : MidiMessage -> Cmd msg


port midiInPort : (MidiMessage -> msg) -> Sub msg


port panicPort : ({} -> msg) -> Sub msg


port oscillator1WaveformPort : String -> Cmd msg


port oscillator2WaveformPort : String -> Cmd msg


port oscillator2SemitonePort : Int -> Cmd msg


port oscillator2DetunePort : Int -> Cmd msg


port oscillatorsBalancePort : Int -> Cmd msg


port fmAmountPort : Int -> Cmd msg


port ampVolumePort : Int -> Cmd msg


port ampAttackPort : Int -> Cmd msg


port ampDecayPort : Int -> Cmd msg


port ampSustainPort : Int -> Cmd msg


port pulseWidthPort : Int -> Cmd msg


port filterCutoffPort : Int -> Cmd msg


port filterQPort : Int -> Cmd msg


port filterTypePort : String -> Cmd msg
