module Container.Panel.Model exposing (..)

-- where

import Component.Knob as Knob exposing (..)
import Component.Switch as Switch exposing (..)
import Component.OptionPicker as OptionPicker exposing (..)
import Port
import Preset


type OscillatorWaveform
    = Sawtooth
    | Triangle
    | Sine
    | Square
    | Pulse
    | WhiteNoise


createOscillatorWaveform : String -> OscillatorWaveform
createOscillatorWaveform name =
    case name of
        "sawtooth" ->
            Sawtooth

        "triangle" ->
            Triangle

        "sine" ->
            Sine

        "square" ->
            Square

        "whitenoise" ->
            WhiteNoise

        _ ->
            Debug.crash <| "invalid waveform " ++ (toString name)


type FilterType
    = Lowpass
    | Highpass
    | Bandpass
    | Notch


createFilterType : String -> FilterType
createFilterType name =
    case name of
        "lowpass" ->
            Lowpass

        "highpass" ->
            Highpass

        "bandpass" ->
            Bandpass

        "notch" ->
            Notch

        _ ->
            Debug.crash <| "invalid filter type " ++ (toString name)


type alias Model =
    { knobs : List Knob.Model
    , filterTypeBtn : OptionPicker.Model FilterType
    , osc2WaveformBtn : OptionPicker.Model OscillatorWaveform
    , osc1WaveformBtn : OptionPicker.Model OscillatorWaveform
    , osc2KbdTrackSwitch : Switch.Model
    , overdriveSwitch : Switch.Model
    }


knobs : Preset.Preset -> List Knob.Model
knobs preset =
    [ Knob.init Knob.OscMix
        preset.oscs.mix
        0
        127
        1
        "OscMix"
        Port.oscsBalance
    , Knob.init Knob.PW
        preset.oscs.pw
        0
        127
        1
        "PW"
        Port.pulseWidth
    , Knob.init Knob.Osc2Semitone
        preset.oscs.osc2.semitone
        -60
        60
        1
        "semitone"
        Port.osc2Semitone
    , Knob.init Knob.Osc2Detune
        preset.oscs.osc2.detune
        -100
        100
        1
        "detune"
        Port.osc2Detune
    , Knob.init Knob.FM
        preset.oscs.osc1.fmGain
        0
        127
        1
        "FM"
        Port.fmAmount
    , Knob.init Knob.AmpGain
        preset.amp.masterVolume
        0
        127
        1
        "gain"
        Port.ampVolume
    , Knob.init Knob.AmpAttack
        preset.amp.adsr.attack
        0
        127
        1
        "attack"
        Port.ampAttack
    , Knob.init Knob.AmpDecay
        preset.amp.adsr.decay
        0
        127
        1
        "decay"
        Port.ampDecay
    , Knob.init Knob.AmpSustain
        preset.amp.adsr.sustain
        0
        127
        1
        "sustain"
        Port.ampSustain
    , Knob.init Knob.AmpRelease
        preset.amp.adsr.release
        0
        127
        1
        "release"
        Port.ampRelease
    , Knob.init Knob.FilterCutoff
        preset.filter.frequency
        0
        127
        1
        "frequency"
        Port.filterCutoff
    , Knob.init Knob.FilterQ
        preset.filter.q
        0
        127
        1
        "resonance"
        Port.filterQ
    , Knob.init Knob.FilterAttack
        preset.filter.adsr.attack
        0
        127
        1
        "attack"
        Port.filterAttack
    , Knob.init Knob.FilterDecay
        preset.filter.adsr.decay
        0
        127
        1
        "decay"
        Port.filterDecay
    , Knob.init Knob.FilterSustain
        preset.filter.adsr.sustain
        0
        127
        1
        "sustain"
        Port.filterSustain
    , Knob.init Knob.FilterRelease
        preset.filter.adsr.release
        0
        127
        1
        "release"
        Port.filterRelease
    , Knob.init Knob.FilterEnvelopeAmount
        preset.filter.envelopeAmount
        0
        127
        1
        "env amnt"
        Port.filterEnvelopeAmount
    ]


init : Preset.Preset -> Model
init preset =
    { knobs = knobs preset
    , osc2KbdTrackSwitch =
        Switch.init preset.oscs.osc2.kbdTrack Port.osc2KbdTrack
    , overdriveSwitch =
        Switch.init preset.overdrive Port.overdrive
    , filterTypeBtn =
        OptionPicker.init Port.filterType
            (createFilterType preset.filter.type_)
            [ ( "LP", Lowpass )
            , ( "HP", Highpass )
            , ( "BP", Bandpass )
            , ( "notch", Notch )
            ]
    , osc1WaveformBtn =
        OptionPicker.init Port.osc1Waveform
            (createOscillatorWaveform preset.oscs.osc1.waveformType)
            [ ( "sin", Sine )
            , ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            ]
    , osc2WaveformBtn =
        OptionPicker.init Port.osc2Waveform
            (createOscillatorWaveform preset.oscs.osc2.waveformType)
            [ ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "pulse", Pulse )
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


updateOverdriveSwitch : Switch.Model -> Model -> Model
updateOverdriveSwitch switch model =
    { model | overdriveSwitch = switch }
