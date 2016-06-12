module Msg exposing (..)

-- where

import Model.Model exposing (..)
import Model.Midi exposing (..)
import Components.Knob as Knob exposing (..)
import Components.OnScreenKeyboard as OnScreenKeyboard exposing (..)


type Msg
    = Oscillator1WaveformChange OscillatorWaveform
    | Oscillator2WaveformChange OscillatorWaveform
    | Oscillator2SemitoneChange Knob.Msg
    | Oscillator2DetuneChange Knob.Msg
    | FMAmountChange Knob.Msg
    | PulseWidthChange Knob.Msg
    | OscillatorsMixChange Knob.Msg
    | MasterVolumeChange Knob.Msg
    | OctaveUp OnScreenKeyboard.Msg
    | OctaveDown OnScreenKeyboard.Msg
    | VelocityUp OnScreenKeyboard.Msg
    | VelocityDown OnScreenKeyboard.Msg
    | MouseEnter OnScreenKeyboard.Msg
    | MouseLeave OnScreenKeyboard.Msg
    | KeyOn OnScreenKeyboard.Msg
    | KeyOff OnScreenKeyboard.Msg
    | MouseClickUp OnScreenKeyboard.Msg
    | MouseClickDown OnScreenKeyboard.Msg
    | MidiMessageIn OnScreenKeyboard.Msg
    | NoOp OnScreenKeyboard.Msg
