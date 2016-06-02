module Msg exposing (..) -- where

type Msg
  = NoOp
  | OctaveUp
  | OctaveDown
  | VelocityUp
  | VelocityDown
  | KeyOn Char
  | KeyOff Char
  | MasterVolumeChange Float
  | OscillatorsBalanceChange Float
  | Oscillator1DetuneChange Float
  | Oscillator2DetuneChange Float