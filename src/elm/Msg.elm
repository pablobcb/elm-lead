module Msg exposing (..)

-- where

import Model.Model exposing (..)
import Model.Midi exposing (..)
import Knob exposing (..)


type Msg
    = NoOp
    | OctaveUp
    | OctaveDown
    | VelocityUp
    | VelocityDown
    | MouseEnter MidiNote
    | MouseLeave MidiNote
    | KeyOn Char
    | KeyOff Char
    | MouseClickUp
    | MouseClickDown
    | MidiMessageIn MidiMessage
    | Oscillator1WaveformChange OscillatorWaveform
    | Oscillator2WaveformChange OscillatorWaveform
    | Oscillator2SemitoneChange Knob.Msg
    | Oscillator2DetuneChange Knob.Msg
    | FMAmountChange Knob.Msg
    | PulseWidthChange Knob.Msg
    | OscillatorsMixChange Knob.Msg
    | MasterVolumeChange Knob.Msg
