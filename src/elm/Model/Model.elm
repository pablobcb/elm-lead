module Model.Model exposing (..)

-- where

import Model.Note as Note exposing (..)
import Model.Midi as Midi exposing (..)
<<<<<<< Updated upstream
import Components.OnScreenKeyboard as OnScreenKeyboard exposing (..)
import Components.Knob as Knob
=======
import Model.OnScreenKeyboard 
  as OnScreenKeyboard exposing (..)
>>>>>>> Stashed changes


type alias PressedKey =
    ( Char, MidiNote )

<<<<<<< Updated upstream

type OscillatorWaveform
    = Sawtooth
    | Triangle
    | Sine
    | Square


type alias Model =
    --OSC
    { onScreenKeyboard : OnScreenKeyboard.Model
    , oscillatorsMixKnob : Knob.Model
    , oscillator1Waveform : OscillatorWaveform
    , oscillator2SemitoneKnob : Knob.Model
    , oscillator2DetuneKnob : Knob.Model
    , oscillator2Waveform : OscillatorWaveform
    , pulseWidthKnob : Knob.Model
    , fmAmountKnob :
        Knob.Model
        --AMP
    , ampAttackKnob : Knob.Model
    , ampDecayKnob : Knob.Model
    , ampSustainKnob : Knob.Model
    , ampReleaseKnob : Knob.Model
    , masterVolumeKnob : Knob.Model
    , filterAttackKnob :
        Knob.Model
        -- FILTER
    , filterDecayKnob : Knob.Model
    , filterSustainKnob : Knob.Model
    , filterReleaseKnob : Knob.Model
    }


initModel : Model
initModel =
    { onScreenKeyboard = initOnScreenKeyboard
    , oscillatorsMixKnob = Knob.create 0 -50 50 1
    , oscillator2SemitoneKnob = Knob.create 0 -60 60 1
    , oscillator2DetuneKnob = Knob.create 0 -100 100 1
    , oscillator1Waveform = Sawtooth
    , oscillator2Waveform = Sawtooth
    , fmAmountKnob = Knob.create 0 0 100 1
    , pulseWidthKnob = Knob.create 0 0 100 1
    , ampAttackKnob = Knob.create 0 0 100 1
    , ampDecayKnob = Knob.create 0 0 100 1
    , ampSustainKnob = Knob.create 0 0 100 1
    , ampReleaseKnob = Knob.create 0 0 100 1
    , masterVolumeKnob = Knob.create 10 0 100 1
    , filterAttackKnob = Knob.create 0 0 100 1
    , filterDecayKnob = Knob.create 0 0 100 1
    , filterSustainKnob = Knob.create 0 0 100 1
    , filterReleaseKnob = Knob.create 0 0 100 1
    }


setFmAmount : Knob.Model -> Model -> Model
setFmAmount knobModel model =
    { model | fmAmountKnob = knobModel }


setPulseWidth : Knob.Model -> Model -> Model
setPulseWidth knobModel model =
    { model | oscillator2DetuneKnob = knobModel }


setOscillator2Detune : Knob.Model -> Model -> Model
setOscillator2Detune knobModel model =
    { model | oscillator2DetuneKnob = knobModel }


setOscillator2Semitone : Knob.Model -> Model -> Model
setOscillator2Semitone knobModel model =
    { model | oscillator2SemitoneKnob = knobModel }


setMasterVolume : Knob.Model -> Model -> Model
setMasterVolume knobModel model =
    { model | masterVolumeKnob = knobModel }


setOscillatorsMix : Knob.Model -> Model -> Model
setOscillatorsMix knobModel model =
    { model | oscillatorsMixKnob = knobModel }


setOscillator1Waveform : Model -> OscillatorWaveform -> Model
setOscillator1Waveform model waveform =
    { model | oscillator1Waveform = waveform }


setOscillator2Waveform : Model -> OscillatorWaveform -> Model
setOscillator2Waveform model waveform =
    { model | oscillator2Waveform = waveform }


setOnScreenKeyboard : OnScreenKeyboard.Model -> Model -> Model
setOnScreenKeyboard keyboard model =
    { model | onScreenKeyboard = keyboard }
=======
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

>>>>>>> Stashed changes
