module Container.Panel.Model exposing (..)

-- where

import Component.Knob as Knob exposing (..)
import Component.Switch as Switch exposing (..)
import Component.OptionPicker as OptionPicker exposing (..)
import Port


type OscillatorWaveform
    = Sawtooth
    | Triangle
    | Sine
    | Square
    | WhiteNoise


type FilterType
    = Lowpass
    | Highpass
    | Bandpass
    | Notch


type alias Model =
    { knobs : List Knob.Model
    , filterTypeBtn : OptionPicker.Model FilterType
    , oscillator2WaveformBtn : OptionPicker.Model OscillatorWaveform
    , oscillator1WaveformBtn : OptionPicker.Model OscillatorWaveform
    , oscillator2KbdTrackSwitch : Switch.Model
    }



knobs : List Knob.Model
knobs =
    [ Knob.init Knob.OscMix 0 -50 50 1 "OscMix" Port.oscillatorsBalance
    , Knob.init Knob.PW 0 0 127 1 "PW" Port.pulseWidth
    , Knob.init Knob.Osc2Semitone 0 -60 60 1 "semitone" Port.oscillator2Semitone
    , Knob.init Knob.Osc2Detune 0 -100 100 1 "detune" Port.oscillator2Detune
    , Knob.init Knob.FM 0 0 127 1 "FM" Port.fmAmount
    , Knob.init Knob.AmpGain 10 0 127 1 "gain" Port.ampVolume
    , Knob.init Knob.AmpAttack 10 0 127 1 "attack" Port.ampAttack
    , Knob.init Knob.AmpDecay 10 0 127 1 "decay" Port.ampDecay
    , Knob.init Knob.AmpSustain 10 0 127 1 "sustain" Port.ampSustain
    , Knob.init Knob.FilterCutoff 64 0 127 1 "frequency" Port.filterCutoff
    , Knob.init Knob.FilterQ 1 0 127 1 "resonance" Port.filterQ
    ]


findKnob : Model -> KnobInstance -> Knob.Model
findKnob model knobInstance =
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
    , oscillator2KbdTrackSwitch = Switch.init True Port.oscillator2KbdTrack
    , filterTypeBtn =
        OptionPicker.init
            [ ( "LP", Lowpass )
            , ( "HP", Highpass )
            , ( "BP", Bandpass )
            , ( "notch", Notch )
            ]
    , oscillator1WaveformBtn =
        OptionPicker.init
            [ ( "sin", Sine )
            , ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            ]
    , oscillator2WaveformBtn =
        OptionPicker.init
            [ ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "pulse", Square )
            , ( "noise", WhiteNoise )
            ]
    }


updateOscillator1WaveformBtn : OptionPicker.Model OscillatorWaveform -> Model -> Model
updateOscillator1WaveformBtn btn model =
    { model | oscillator1WaveformBtn = btn }


updateOscillator2WaveformBtn : OptionPicker.Model OscillatorWaveform -> Model -> Model
updateOscillator2WaveformBtn btn model =
    { model | oscillator2WaveformBtn = btn }

updateOscillator2KbdTrack : Switch.Model -> Model -> Model
updateOscillator2KbdTrack switch model =
    { model | oscillator2KbdTrackSwitch = switch }

updateFilterTypeBtn : OptionPicker.Model FilterType -> Model -> Model
updateFilterTypeBtn btn model =
    { model | filterTypeBtn = btn }
