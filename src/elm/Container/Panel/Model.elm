module Container.Panel.Model exposing (..)

-- where

import Component.Knob as Knob exposing (..)
import Component.NordButton as Button exposing (..)


type OscillatorWaveform
    = Sawtooth
    | Triangle
    | Sine
    | Square


type FilterType
    = Lowpass
    | Highpass
    | Bandpass
    | Notch



-- TODO : prefix all knobs with section name


type alias Model =
    { oscillatorsMixKnob : Knob.Model
    , oscillatorsPulseWidthKnob : Knob.Model
    , oscillator1WaveformBtn : Button.Model OscillatorWaveform
    , oscillator1FmAmountKnob : Knob.Model
    , oscillator2WaveformBtn : Button.Model OscillatorWaveform
    , oscillator2SemitoneKnob : Knob.Model
    , oscillator2DetuneKnob : Knob.Model
    , ampAttackKnob : Knob.Model
    , ampDecayKnob : Knob.Model
    , ampSustainKnob : Knob.Model
    , ampReleaseKnob : Knob.Model
    , ampVolumeKnob : Knob.Model
    , filterCutoffKnob : Knob.Model
    , filterQKnob : Knob.Model
    , filterTypeBtn : Button.Model FilterType
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
    , oscillator1FmAmountKnob = Knob.init 0 0 100 1
    , oscillator2WaveformBtn =
        Button.init
            [ ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            , ( "noise", Square )
            ]
    , oscillatorsPulseWidthKnob = Knob.init 0 0 100 1
    , ampAttackKnob = Knob.init 0 0 100 1
    , ampDecayKnob = Knob.init 0 0 100 1
    , ampSustainKnob = Knob.init 0 0 100 1
    , ampReleaseKnob = Knob.init 0 0 100 1
    , ampVolumeKnob = Knob.init 10 0 100 1
    , filterCutoffKnob = Knob.init 4000 0 10000 1
    , filterQKnob = Knob.init 1 0 45 1
    , filterTypeBtn =
        Button.init
            [ ( "LP", Lowpass )
            , ( "HP", Highpass )
            , ( "BP", Bandpass )
            , ( "notch", Notch )
            ]
    , filterAttackKnob = Knob.init 0 0 100 1
    , filterDecayKnob = Knob.init 0 0 100 1
    , filterSustainKnob = Knob.init 0 0 100 1
    , filterReleaseKnob = Knob.init 0 0 100 1
    }


setOscillator1FmAmountKnob : Knob.Model -> Model -> Model
setOscillator1FmAmountKnob knobModel model =
    { model | oscillator1FmAmountKnob = knobModel }


setPulseWidthKnob : Knob.Model -> Model -> Model
setPulseWidthKnob knobModel model =
    { model | oscillatorsPulseWidthKnob = knobModel }


setOscillator2DetuneKnob : Knob.Model -> Model -> Model
setOscillator2DetuneKnob knobModel model =
    { model | oscillator2DetuneKnob = knobModel }


setOscillator2SemitoneKnob : Knob.Model -> Model -> Model
setOscillator2SemitoneKnob knobModel model =
    { model | oscillator2SemitoneKnob = knobModel }


setFilterCutoffKnob : Knob.Model -> Model -> Model
setFilterCutoffKnob knobModel model =
    { model | filterCutoffKnob = knobModel }


setFilterQKnob : Knob.Model -> Model -> Model
setFilterQKnob knobModel model =
    { model | filterQKnob = knobModel }


setFilterTypeBtn : Button.Model FilterType -> Model -> Model
setFilterTypeBtn btn model =
    { model | filterTypeBtn = btn }


setAmpVolumeKnob : Knob.Model -> Model -> Model
setAmpVolumeKnob knobModel model =
    { model | ampVolumeKnob = knobModel }


setOscillatorsMixKnob : Knob.Model -> Model -> Model
setOscillatorsMixKnob knobModel model =
    { model | oscillatorsMixKnob = knobModel }


setOscillator1WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
setOscillator1WaveformBtn btn model =
    { model | oscillator1WaveformBtn = btn }


setOscillator2WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
setOscillator2WaveformBtn btn model =
    { model | oscillator2WaveformBtn = btn }
