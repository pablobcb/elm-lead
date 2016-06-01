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
  | OscillatorVolumeChange String
  | OscillatorDetuneChange String