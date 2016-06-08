module Msg exposing (..) -- where
import Model.Model exposing (..)

type Msg
  = NoOp
  | OctaveUp
  | OctaveDown
  | VelocityUp
  | VelocityDown
  | MouseEnter Int
  | MouseLeave Int
  | KeyOn Char
  | KeyOff Char
  | MouseClickUp
  | MouseClickDown
  | MasterVolumeChange Float
  | OscillatorsBalanceChange Float
  | Oscillator1WaveformChange OscillatorWaveform
  | Oscillator2SemitoneChange Float
  | Oscillator2DetuneChange Float
  | FMAmountChange Float
