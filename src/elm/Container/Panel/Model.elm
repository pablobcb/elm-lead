module Container.Panel.Model exposing (..)

-- where

import Component.Knob as Knob exposing (..)
import Component.NordButton as Button exposing (..)
import Port exposing (..)
import Dict exposing (..)


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


type KnobInstance
    = OscMix
    | PW
    | Osc2Semitone
    | Osc2Detune
    | FM
    | AmpGain
    | FilterCutoff
    | FilterQ


type alias Model =
    { knobs : Dict String Knob.Model
    , filterTypeBtn : Button.Model FilterType
    , oscillator2WaveformBtn : Button.Model OscillatorWaveform
    , oscillator1WaveformBtn : Button.Model OscillatorWaveform
    }



--TODO: colocar as portas dos botoes no model


knobs : Dict String Knob.Model
knobs =
    let
        knob instance current min max step port' =
            ( (toString instance)
            , Knob.init current min max step port'
            )
    in
        Dict.fromList
            [ knob OscMix 0 -50 50 1 oscillatorsBalancePort
            , knob PW 0 0 100 1 pulseWidthPort
            , knob Osc2Semitone 0 -60 60 1 oscillator2SemitonePort
            , knob Osc2Detune 0 -100 100 1 oscillator2DetunePort
            , knob FM 0 0 100 1 fmAmountPort
            , knob AmpGain 10 0 100 1 masterVolumePort
            , knob FilterCutoff 4000 0 10000 1 filterCutoffPort
            , knob FilterQ 1 0 45 1 filterQPort
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
