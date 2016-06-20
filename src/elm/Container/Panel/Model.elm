module Container.Panel.Model exposing (..)

-- where

import Component.Knob as Knob exposing (..)
import Component.NordButton as Button exposing (..)
import Port exposing (..)


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
    --, ampAttackKnob : Knob.Model
    --, ampDecayKnob : Knob.Model
    --, ampSustainKnob : Knob.Model
    --, ampReleaseKnob : Knob.Model
    , ampVolumeKnob : Knob.Model
    , filterCutoffKnob : Knob.Model
    , filterQKnob : Knob.Model
    , filterTypeBtn : Button.Model FilterType
    --, filterAttackKnob : Knob.Model
    --, filterDecayKnob : Knob.Model
    --, filterSustainKnob : Knob.Model
    --, filterReleaseKnob : Knob.Model
    }


init : Model
init =
    { oscillatorsMixKnob = Knob.init 0 -50 50 1 oscillatorsBalancePort
    , oscillatorsPulseWidthKnob = Knob.init 0 0 100 1 pulseWidthPort
    , oscillator2SemitoneKnob = Knob.init 0 -60 60 1 oscillator2SemitonePort
    , oscillator2DetuneKnob = Knob.init 0 -100 100 1 oscillator2DetunePort
    , oscillator1WaveformBtn =
        Button.init
            [ ( "sin", Sine )
            , ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            ]
    , oscillator1FmAmountKnob = Knob.init 0 0 100 1 fmAmountPort
    , oscillator2WaveformBtn =
        Button.init
            [ ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            , ( "noise", Square )
            ]
    --, ampAttackKnob = Knob.init 0 0 100 1
    --, ampDecayKnob = Knob.init 0 0 100 1
    --, ampSustainKnob = Knob.init 0 0 100 1
    --, ampReleaseKnob = Knob.init 0 0 100 1
    , ampVolumeKnob = Knob.init 10 0 100 1 masterVolumePort
    , filterCutoffKnob = Knob.init 4000 0 10000 1 filterCutoffPort
    , filterQKnob = Knob.init 1 0 45 1 filterQPort
    , filterTypeBtn =
        Button.init
            [ ( "LP", Lowpass )
            , ( "HP", Highpass )
            , ( "BP", Bandpass )
            , ( "notch", Notch )
            ]
    --, filterAttackKnob = Knob.init 0 0 100 1
    --, filterDecayKnob = Knob.init 0 0 100 1
    --, filterSustainKnob = Knob.init 0 0 100 1
    --, filterReleaseKnob = Knob.init 0 0 100 1
    }

----mouseUp : Model -> Model
--mouseUp = updateKnobs Knob.unClick
--
--mouseMove = updateKnobs
--
----updateKnobs : Model -> Model
----broadcastar essa msg pra todos os knobs
--updateKnobs updater model =
--    { model
--        | oscillatorsMixKnob = updater model.oscillatorsMixKnob
--        , oscillatorsPulseWidthKnob = updater model.oscillatorsPulseWidthKnob
--        , oscillator1FmAmountKnob =  updater model.oscillator1FmAmountKnob
--        , oscillator2SemitoneKnob = updater model.oscillator2SemitoneKnob
--        , oscillator2DetuneKnob = updater model.oscillatorsMixKnob
--        --, ampAttackKnob = Knob.unClick model.ampAttackKnob
--        --, ampDecayKnob = Knob.unClick model.ampDecayKnob
--        --, ampSustainKnob = Knob.unClick model.ampSustainKnob
--        --, ampReleaseKnob = Knob.unClick model.ampReleaseKnob
--        , ampVolumeKnob = updater model.ampVolumeKnob
--        , filterCutoffKnob = updater model.filterCutoffKnob
--        , filterQKnob =updater model.filterQKnob
--        --, filterAttackKnob = Knob.unClick model.filterAttackKnob
--        --, filterDecayKnob = Knob.unClick model.filterDecayKnob
--        --, filterSustainKnob = Knob.unClick model.filterSustainKnob
--        --, filterReleaseKnob = Knob.unClick model.filterReleaseKnob
--    }


updateOscillator1FmAmountKnob : Knob.Model -> Model -> Model
updateOscillator1FmAmountKnob knobModel model =
    { model | oscillator1FmAmountKnob = knobModel }


updatePulseWidthKnob : Knob.Model -> Model -> Model
updatePulseWidthKnob knobModel model =
    { model | oscillatorsPulseWidthKnob = knobModel }


updateOscillator2DetuneKnob : Knob.Model -> Model -> Model
updateOscillator2DetuneKnob knobModel model =
    { model | oscillator2DetuneKnob = knobModel }


updateOscillator2SemitoneKnob : Knob.Model -> Model -> Model
updateOscillator2SemitoneKnob knobModel model =
    { model | oscillator2SemitoneKnob = knobModel }


updateFilterCutoffKnob : Knob.Model -> Model -> Model
updateFilterCutoffKnob knobModel model =
    { model | filterCutoffKnob = knobModel }


updateFilterQKnob : Knob.Model -> Model -> Model
updateFilterQKnob knobModel model =
    { model | filterQKnob = knobModel }


updateFilterTypeBtn : Button.Model FilterType -> Model -> Model
updateFilterTypeBtn btn model =
    { model | filterTypeBtn = btn }


updateAmpVolumeKnob : Knob.Model -> Model -> Model
updateAmpVolumeKnob knobModel model =
    { model | ampVolumeKnob = knobModel }


updateOscillatorsMixKnob : Knob.Model -> Model -> Model
updateOscillatorsMixKnob knobModel model =
    { model | oscillatorsMixKnob = knobModel }


updateOscillator1WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
updateOscillator1WaveformBtn btn model =
    { model | oscillator1WaveformBtn = btn }


updateOscillator2WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
updateOscillator2WaveformBtn btn model =
    { model | oscillator2WaveformBtn = btn }
