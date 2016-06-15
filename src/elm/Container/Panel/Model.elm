module Container.Panel.Model exposing (..)

-- where

import Component.Knob as Knob exposing (..)
import Component.NordButton as Button exposing (..)


type OscillatorWaveform
    = Sawtooth
    | Triangle
    | Sine
    | Square
    | WhiteNoise



-- TODO : prefix all knobs with section name


type alias Model =
    { oscillatorsMixKnob : Knob.Model
    , oscillator1WaveformBtn : Button.Model OscillatorWaveform
    , oscillator2WaveformBtn : Button.Model OscillatorWaveform
    , oscillator2SemitoneKnob : Knob.Model
    , oscillator2DetuneKnob : Knob.Model
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
    { oscillatorsMixKnob = Knob.init 0 -50 50 1
    , oscillator2SemitoneKnob = Knob.init 0 -60 60 1
    , oscillator2DetuneKnob = Knob.init 0 -100 100 1
    , oscillator1WaveformBtn =
        Button.init
            [ ( "sin", Sine )
            , ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            ]
    , oscillator2WaveformBtn =
        Button.init
            [ ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            , ( "noise", WhiteNoise )
            ]
    , fmAmountKnob = Knob.init 0 0 100 1
    , pulseWidthKnob = Knob.init 0 0 100 1
    , ampAttackKnob = Knob.init 0 0 100 1
    , ampDecayKnob = Knob.init 0 0 100 1
    , ampSustainKnob = Knob.init 0 0 100 1
    , ampReleaseKnob = Knob.init 0 0 100 1
    , masterVolumeKnob = Knob.init 10 0 100 1
    , filterAttackKnob = Knob.init 0 0 100 1
    , filterDecayKnob = Knob.init 0 0 100 1
    , filterSustainKnob = Knob.init 0 0 100 1
    , filterReleaseKnob = Knob.init 0 0 100 1
    }


setFmAmount : Knob.Model -> Model -> Model
setFmAmount knobModel model =
    { model | fmAmountKnob = knobModel }


setPulseWidth : Knob.Model -> Model -> Model
setPulseWidth knobModel model =
    { model | pulseWidthKnob = knobModel }


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


setOscillator1WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
setOscillator1WaveformBtn btn model =
    { model | oscillator1WaveformBtn = btn }


setOscillator2WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
setOscillator2WaveformBtn btn model =
    { model | oscillator2WaveformBtn = btn }
