module Msg exposing (..) -- where
import Model.Model exposing (..)
import Model.Midi exposing (..)

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
  | MidiMessageIn MidiMessage --used for changing the key style to pressed/unpress
  
  | MasterVolumeChange Float
  | OscillatorsBalanceChange Float
  | Oscillator1WaveformChange OscillatorWaveform
  | Oscillator2WaveformChange OscillatorWaveform
  | Oscillator2SemitoneChange Float
  | Oscillator2DetuneChange Float
  | FMAmountChange Float
  | PulseWidthChange Float
