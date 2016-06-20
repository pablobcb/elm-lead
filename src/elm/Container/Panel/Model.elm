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
    { knobs : List Knob.Model
    , filterTypeBtn : Button.Model FilterType
    , oscillator2WaveformBtn : Button.Model OscillatorWaveform
    , oscillator1WaveformBtn : Button.Model OscillatorWaveform
    }

--TODO: colocar as portas dos botoes no model
init : Model
init =
    { knobs = 
        [ Knob.init 0 -50 50 1 oscillatorsBalancePort
        , Knob.init 0 0 100 1 pulseWidthPort
        , Knob.init 0 -60 60 1 oscillator2SemitonePort
        , Knob.init 0 -100 100 1 oscillator2DetunePort
        , Knob.init 0 0 100 1 fmAmountPort
        , Knob.init 10 0 100 1 masterVolumePort
        , Knob.init 4000 0 10000 1 filterCutoffPort
        , Knob.init 1 0 45 1 filterQPort
        ]
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