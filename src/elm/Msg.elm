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
    | OnScreenKeyboardMsg OnScreenKeyboard.Msg
