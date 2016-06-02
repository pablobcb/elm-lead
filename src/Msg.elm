module Msg exposing (..) -- where

type Msg
  = NoOp
  | OctaveUp
  | OctaveDown
  | VelocityUp
  | VelocityDown
  | KeyOn Char
  | KeyOff Char
  | MouseClickUp
  | MouseClickDown
  | MasterVolumeChange Float
  | OscillatorsBalanceChange Float
  | Oscillator1DetuneChange Float
  | Oscillator2DetuneChange Float