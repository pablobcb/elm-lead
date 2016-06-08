module Msg exposing (..) -- where

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
  | Oscillator2SemitoneChange Float
  | Oscillator2DetuneChange Float
