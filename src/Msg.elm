module Msg exposing (..) -- where

type Msg
  = NoOp
  | OctaveUp
  | OctaveDown
  | VelocityUp
  | VelocityDown
  | KeyOn Char
  | KeyOff Char
  | MasterVolumeChange String
  | OscillatorsBalanceChange String
  | Oscillator1DetuneChange String
  | Oscillator2DetuneChange String