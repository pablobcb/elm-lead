port module Port exposing (..)

import Midi exposing (..)


port midiOut : MidiMessage -> Cmd msg


port midiIn : (MidiMessage -> msg) -> Sub msg


port panic : ({} -> msg) -> Sub msg


port oscillator1Waveform : String -> Cmd msg


port oscillator2Waveform : String -> Cmd msg


port oscillator2Semitone : Int -> Cmd msg


port oscillator2Detune : Int -> Cmd msg


port oscillator2KbdTrack : Bool -> Cmd msg


port oscillatorsBalance : Int -> Cmd msg


port fmAmount : Int -> Cmd msg


port ampVolume : Int -> Cmd msg


port ampAttack : Int -> Cmd msg


port ampDecay : Int -> Cmd msg


port ampSustain : Int -> Cmd msg


port pulseWidth : Int -> Cmd msg


port filterCutoff : Int -> Cmd msg


port filterQ : Int -> Cmd msg


port filterType : String -> Cmd msg
