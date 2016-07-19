module Container.Panel.Model
    exposing
        ( FilterType(..)
        , Model
        , Waveform(..)
        , init
        , updateOverdriveSwitch
        , updateOsc2KbdTrack
        , updateFilterTypeBtn
        , updateOsc2WaveformBtn
        , updateOsc1WaveformBtn
        , updateLfo1DestinationBtn
        , updateLfo1WaveformBtn
        )

import Component.Knob as Knob
import Component.Switch as Switch
import Component.OptionPicker as OptionPicker
import Port
import Preset


type Waveform
    = Sawtooth
    | Triangle
    | Sine
    | Square
    | Pulse
    | WhiteNoise


createWaveform : String -> Waveform
createWaveform name =
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
    , lfo1DestinationBtn : OptionPicker.Model Destination
    , lfo1WaveformBtn : OptionPicker.Model Waveform
    , filterTypeBtn : OptionPicker.Model FilterType
    , osc2WaveformBtn : OptionPicker.Model Waveform
    , osc1WaveformBtn : OptionPicker.Model Waveform
    , osc2KbdTrackSwitch : Switch.Model
    , overdriveSwitch : Switch.Model
    }


knobs : Preset.Preset -> List Knob.Model
knobs preset =
    [ Knob.init Knob.OscMix preset.oscs.mix
        0 127 1 "Mix" Port.oscsMix

    , Knob.init Knob.PW preset.oscs.osc2.pw
        0 127 1 "Pulse width" Port.pulseWidth

    , Knob.init Knob.Osc2Semitone preset.oscs.osc2.semitone
        -60 60 1 "Semitones" Port.osc2Semitone

    , Knob.init Knob.Osc2Detune preset.oscs.osc2.detune
        -100 100 1 "Fine tune" Port.osc2Detune

    , Knob.init Knob.FM preset.oscs.osc1.fmAmount
        0 127 1 "FM amount" Port.fmAmount

    , Knob.init Knob.AmpGain preset.amp.masterVolume
        0 127 1 "Gain" Port.ampVolume

    , Knob.init Knob.AmpAttack preset.amp.adsr.attack
        0 127 1 "Attack" Port.ampAttack

    , Knob.init Knob.AmpDecay preset.amp.adsr.decay
        0 127 1 "Decay" Port.ampDecay

    , Knob.init Knob.AmpSustain preset.amp.adsr.sustain
        0 127 1 "Sustain" Port.ampSustain

    , Knob.init Knob.AmpRelease preset.amp.adsr.release
        0 127 1 "Release" Port.ampRelease

    , Knob.init Knob.FilterCutoff preset.filter.frequency
        0 127 1 "Frequency" Port.filterCutoff

    , Knob.init Knob.FilterQ preset.filter.q
        0 127 1 "Resonance" Port.filterQ

    , Knob.init Knob.FilterAttack preset.filter.adsr.attack
        0 127 1 "Attack" Port.filterAttack

    , Knob.init Knob.FilterDecay preset.filter.adsr.decay
        0 127 1 "Decay" Port.filterDecay

    , Knob.init Knob.FilterSustain preset.filter.adsr.sustain
        0 127 1 "Sustain" Port.filterSustain

    , Knob.init Knob.FilterRelease preset.filter.adsr.release
        0 127 1 "Release" Port.filterRelease

    , Knob.init Knob.FilterEnvelopeAmount preset.filter.envelopeAmount
        0 127 1 "Env amount" Port.filterEnvelopeAmount

    , Knob.init Knob.Lfo1Rate preset.lfo1.rate
        0 127 1 "Rate" Port.lfo1Rate

    , Knob.init Knob.Lfo1Amount preset.lfo1.amount
        0 127 1 "Amount" Port.lfo1Amount
    ]

type Destination
    = FM
    | Osc1
    | Osc2
    | Oscs
    | Filter
    | PW
    | Amp


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
            (createWaveform preset.oscs.osc1.waveformType)
            [ ( "sin", Sine )
            , ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            ]
    , osc2WaveformBtn =
        OptionPicker.init Port.osc2Waveform
            (createWaveform preset.oscs.osc2.waveformType)
            [ ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "pulse", Pulse )
            , ( "noise", WhiteNoise )
            ]
    , lfo1DestinationBtn =
        OptionPicker.init Port.lfo1Destination
            Filter
            [ ( "Osc2", Osc2 )
            , ( "Oscs", Oscs )
            , ( "Filter", Filter )
            , ( "FM", FM )
            , ( "PW", PW )
            ]
    , lfo1WaveformBtn =
        OptionPicker.init Port.lfo1Waveform
            Sine
            [ ( "sin", Sine )
            , ( "tri", Triangle )
            , ( "saw", Sawtooth )
            , ( "sqr", Square )
            ]
    }


findKnob : Model -> Knob.KnobInstance -> Knob.Model
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


updateOsc1WaveformBtn : OptionPicker.Model Waveform -> Model -> Model
updateOsc1WaveformBtn btn model =
    { model | osc1WaveformBtn = btn }


updateOsc2WaveformBtn : OptionPicker.Model Waveform -> Model -> Model
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


updateLfo1DestinationBtn : OptionPicker.Model Destination -> Model -> Model
updateLfo1DestinationBtn  btn model =
    { model | lfo1DestinationBtn = btn }


updateLfo1WaveformBtn : OptionPicker.Model Waveform -> Model -> Model
updateLfo1WaveformBtn  btn model =
    { model | lfo1WaveformBtn = btn }