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



-- this datatype is necessary because knobs are stored
-- inside a Dict, so these types will be converted to Strings
-- and used as keys for the Dict, and later referenced by the view
-- (its senseless to use Stringly Typed data
-- within a Strongly Typed Language)
--type KnobInstance
--    = OscMix
--    | PW
--    | Osc2Semitone
--    | Osc2Detune
--    | FM
--    | AmpGain
--    | FilterCutoff
--    | FilterQ


type alias Model =
    { knobs : List Knob.Model
    , filterTypeBtn : Button.Model FilterType
    , oscillator2WaveformBtn : Button.Model OscillatorWaveform
    , oscillator1WaveformBtn : Button.Model OscillatorWaveform
    }



--TODO: colocar as portas dos botoes no model


knobs : List Knob.Model
knobs =
    [ Knob.init Knob.OscMix 0 -50 50 1 oscillatorsBalancePort
    , Knob.init Knob.PW 0 0 100 1 pulseWidthPort
    , Knob.init Knob.Osc2Semitone 0 -60 60 1 oscillator2SemitonePort
    , Knob.init Knob.Osc2Detune 0 -100 100 1 oscillator2DetunePort
    , Knob.init Knob.FM 0 0 100 1 fmAmountPort
    , Knob.init Knob.AmpGain 10 0 100 1 masterVolumePort
    , Knob.init Knob.FilterCutoff 4000 0 10000 1 filterCutoffPort
    , Knob.init Knob.FilterQ 1 0 45 1 filterQPort
    ]


init : Model
init =
    { knobs = knobs
    , filterTypeBtn =
        Button.init
            [ ( "LP", Lowpass )
            , ( "HP", Highpass )
            , ( "BP", Bandpass )
            , ( "notch", Notch )
            ]
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
            , ( "noise", Square )
            ]
    }


updateOscillator1WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
updateOscillator1WaveformBtn btn model =
    { model | oscillator1WaveformBtn = btn }


updateOscillator2WaveformBtn : Button.Model OscillatorWaveform -> Model -> Model
updateOscillator2WaveformBtn btn model =
    { model | oscillator2WaveformBtn = btn }


updateFilterTypeBtn : Button.Model FilterType -> Model -> Model
updateFilterTypeBtn btn model =
    { model | filterTypeBtn = btn }
