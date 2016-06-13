module Container.Panel.Model exposing (..)

-- where

import Component.Knob as Knob exposing (..)


type OscillatorWaveform
    = Sawtooth
    | Triangle
    | Sine
    | Square



-- TODO : prefix all knobs with section name


type alias Model =
    { oscillatorsMixKnob : Knob.Model
    , oscillator1Waveform : OscillatorWaveform
    , oscillator2SemitoneKnob : Knob.Model
    , oscillator2DetuneKnob : Knob.Model
    , oscillator2Waveform : OscillatorWaveform
    , pulseWidthKnob : Knob.Model
    , fmAmountKnob : Knob.Model
    , ampAttackKnob : Knob.Model
    , ampDecayKnob : Knob.Model
    , ampSustainKnob : Knob.Model
    , ampReleaseKnob : Knob.Model
    , masterVolumeKnob : Knob.Model
    , filterAttackKnob : Knob.Model
    , filterDecayKnob : Knob.Model
    , filterSustainKnob : Knob.Model
    , filterReleaseKnob : Knob.Model
    }


init : Model
init =
    { oscillatorsMixKnob = Knob.create 0 -50 50 1
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
