module Model.Model exposing (..) -- where

import Char exposing (..)
import Keyboard exposing (..)
import List exposing (..)
import Maybe.Extra exposing (..)

import Model.Note as Note exposing (..)
import Model.Midi as Midi exposing (..)
import Model.OnScreenKeyboard as OnScreenKeyboard exposing (..)


type OscillatorWaveform 
  = Sawtooth
  | Triangle
  | Sine
  | Square

type alias Model =
  { onScreenKeyboard           : OnScreenKeyboard
  , oscillator1Waveform        : OscillatorWaveform
  , oscillator2Waveform        : OscillatorWaveform
  }

initModel : Model
initModel =
  { onScreenKeyboard           = initOnScreenKeyboard
  , oscillator1Waveform        = Sawtooth
  , oscillator2Waveform        = Sawtooth
  }

setOscillator1Waveform : Model -> OscillatorWaveform -> Model
setOscillator1Waveform model waveform =
  { model | oscillator1Waveform = waveform }

setOscillator2Waveform : Model -> OscillatorWaveform -> Model
setOscillator2Waveform model waveform =
  { model | oscillator2Waveform = waveform }
