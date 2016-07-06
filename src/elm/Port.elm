port module Port exposing (..)

import Midi exposing (..)
import Preset exposing (..)


port midiOut : MidiMessage -> Cmd msg


port midiIn : (MidiMessage -> msg) -> Sub msg


port midiStateChange : (Bool -> msg) -> Sub msg


port panic : ({} -> msg) -> Sub msg


port osc1Waveform : String -> Cmd msg


port osc2Waveform : String -> Cmd msg


port osc2Semitone : Int -> Cmd msg


port osc2Detune : Int -> Cmd msg


port osc2KbdTrack : Bool -> Cmd msg


port oscsBalance : Int -> Cmd msg


port fmAmount : Int -> Cmd msg


port ampVolume : Int -> Cmd msg


port ampAttack : Int -> Cmd msg


port ampDecay : Int -> Cmd msg


port ampSustain : Int -> Cmd msg


port ampRelease : Int -> Cmd msg


port pulseWidth : Int -> Cmd msg


port filterCutoff : Int -> Cmd msg


port filterQ : Int -> Cmd msg


port filterType : String -> Cmd msg


port filterAttack : Int -> Cmd msg


port filterDecay : Int -> Cmd msg


port filterSustain : Int -> Cmd msg


port filterRelease : Int -> Cmd msg


port filterEnvelopeAmount : Int -> Cmd msg


port overdrive : Bool -> Cmd msg


port presetChange : (Preset -> msg) -> Sub msg


port nextPreset : {} -> Cmd msg


port previousPreset : {} -> Cmd msg
