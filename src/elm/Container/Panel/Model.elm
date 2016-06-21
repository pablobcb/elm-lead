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


type alias Model =
    { knobs : List Knob.Model
    , filterTypeBtn : Button.Model FilterType
    , oscillator2WaveformBtn : Button.Model OscillatorWaveform
    , oscillator1WaveformBtn : Button.Model OscillatorWaveform
    }



--TODO: colocar as portas dos botoes no model


knobs : List Knob.Model
knobs =
    [ Knob.init Knob.OscMix 0 -50 50 2 oscillatorsBalancePort
    , Knob.init Knob.PW 0 0 100 2 pulseWidthPort
    , Knob.init Knob.Osc2Semitone 0 -60 60 2 oscillator2SemitonePort
    , Knob.init Knob.Osc2Detune 0 -100 100 2 oscillator2DetunePort
    , Knob.init Knob.FM 0 0 100 2 fmAmountPort
    , Knob.init Knob.AmpGain 10 0 100 2 masterVolumePort
    , Knob.init Knob.FilterCutoff 4000 0 20000 50 filterCutoffPort
    , Knob.init Knob.FilterQ 1 0 45 1 filterQPort
    ]

findKnob : Model -> KnobInstance -> Knob.Model
findKnob model knobInstance=
    let 
        knob =
            List.head
                <| List.filter (\knob' -> knob'.idKey == knobInstance)
                    model.knobs
        in 
            case knob of
                Nothing ->
                    Debug.crash "inexistent knob identifier"
    
                Just knobModel ->
                    knobModel
                    


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
