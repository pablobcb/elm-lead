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
    , osc2WaveformBtn : OptionPicker.Model OscillatorWaveform
    , osc1WaveformBtn : OptionPicker.Model OscillatorWaveform
    , osc2KbdTrackSwitch : Switch.Model
    , filterDistortionSwitch : Switch.Model
    }


knobs : List Knob.Model
knobs =
    [ Knob.init Knob.OscMix 0 -50 50 1 "OscMix" Port.oscsBalance
    , Knob.init Knob.PW 0 0 127 1 "PW" Port.pulseWidth
    , Knob.init Knob.Osc2Semitone 0 -60 60 1 "semitone" Port.osc2Semitone
    , Knob.init Knob.Osc2Detune 0 -100 100 1 "detune" Port.osc2Detune
    , Knob.init Knob.FM 0 0 127 1 "FM" Port.fmAmount
    , Knob.init Knob.AmpGain 10 0 127 1 "gain" Port.ampVolume
    , Knob.init Knob.AmpAttack 1 0 127 1 "attack" Port.ampAttack
    , Knob.init Knob.AmpDecay 127 0 127 1 "decay" Port.ampDecay
    , Knob.init Knob.AmpSustain 1 0 127 1 "sustain" Port.ampSustain
    , Knob.init Knob.AmpRelease 127 0 127 1 "release" Port.ampRelease
    , Knob.init Knob.FilterCutoff 127 0 127 1 "frequency" Port.filterCutoff
    , Knob.init Knob.FilterQ 1 0 127 1 "resonance" Port.filterQ
    , Knob.init Knob.FilterAttack 0 0 127 1 "attack" Port.filterAttack
    , Knob.init Knob.FilterDecay 0 0 127 1 "decay" Port.filterDecay
    , Knob.init Knob.FilterSustain 127 0 127 1 "sustain" Port.filterSustain
    , Knob.init Knob.FilterRelease 0 0 127 1 "release" Port.filterRelease
    , Knob.init Knob.FilterEnvelopeAmount
        0
        0
        127
        1
        "Envelope amount"
        Port.filterEnvelopeAmount
    ]


init : Model
init =
    { knobs = knobs
    , osc2KbdTrackSwitch = Switch.init True Port.osc2KbdTrack
    , filterDistortionSwitch = Switch.init False Port.filterDistortion
    , filterTypeBtn =
        OptionPicker.init Port.filterType
            [ ( "LP", Lowpass )
            , ( "HP", Highpass )
            , ( "BP", Bandpass )
            , ( "notch", Notch )
            ]
    , osc1WaveformBtn =
        OptionPicker.init Port.osc1Waveform
            [ ( "sin", Sine )
            , ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            ]
    , osc2WaveformBtn =
        OptionPicker.init Port.osc2Waveform
            [ ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "pulse", Square )
            , ( "noise", WhiteNoise )
            ]
    }


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


updateOsc1WaveformBtn : OptionPicker.Model OscillatorWaveform -> Model -> Model
updateOsc1WaveformBtn btn model =
    { model | osc1WaveformBtn = btn }


updateOsc2WaveformBtn : OptionPicker.Model OscillatorWaveform -> Model -> Model
updateOsc2WaveformBtn btn model =
    { model | osc2WaveformBtn = btn }


updateOsc2KbdTrack : Switch.Model -> Model -> Model
updateOsc2KbdTrack switch model =
    { model | osc2KbdTrackSwitch = switch }


updateFilterTypeBtn : OptionPicker.Model FilterType -> Model -> Model
updateFilterTypeBtn btn model =
    { model | filterTypeBtn = btn }
