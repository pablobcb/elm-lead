module Container.Panel.Panel exposing (..)

-- where

import Components.Knob as Knob
import Ports exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (map)


type OscillatorWaveform
    = Sawtooth
    | Triangle
    | Sine
    | Square



-- TODO : prefix all knobs with section name


type alias Model =
    { oscillatorsMixKnob : Knob.Model
    , oscillator1Waveform : OscillatorWaveform
    , oscillator2SemitoneKnob : Knob.Model
    , oscillator2DetuneKnob : Knob.Model
    , oscillator2Waveform : OscillatorWaveform
    , pulseWidthKnob : Knob.Model
    , fmAmountKnob : Knob.Model
    , ampAttackKnob : Knob.Model
    , ampDecayKnob : Knob.Model
    , ampSustainKnob : Knob.Model
    , ampReleaseKnob : Knob.Model
    , masterVolumeKnob :
        Knob.Model
        -- FILTER
    , filterAttackKnob :
        Knob.Model
    , filterDecayKnob : Knob.Model
    , filterSustainKnob : Knob.Model
    , filterReleaseKnob : Knob.Model
    }


init : Model
init =
    { oscillatorsMixKnob = Knob.create 0 -50 50 1
    , oscillator2SemitoneKnob = Knob.create 0 -60 60 1
    , oscillator2DetuneKnob = Knob.create 0 -100 100 1
    , oscillator1Waveform = Sawtooth
    , oscillator2Waveform = Sawtooth
    , fmAmountKnob = Knob.create 0 0 100 1
    , pulseWidthKnob = Knob.create 0 0 100 1
    , ampAttackKnob = Knob.create 0 0 100 1
    , ampDecayKnob = Knob.create 0 0 100 1
    , ampSustainKnob = Knob.create 0 0 100 1
    , ampReleaseKnob = Knob.create 0 0 100 1
    , masterVolumeKnob = Knob.create 10 0 100 1
    , filterAttackKnob = Knob.create 0 0 100 1
    , filterDecayKnob = Knob.create 0 0 100 1
    , filterSustainKnob = Knob.create 0 0 100 1
    , filterReleaseKnob = Knob.create 0 0 100 1
    }


type Msg
    = Oscillator1WaveformChange OscillatorWaveform
    | Oscillator2WaveformChange OscillatorWaveform
    | Oscillator2SemitoneChange Knob.Msg
    | Oscillator2DetuneChange Knob.Msg
    | FMAmountChange Knob.Msg
    | PulseWidthChange Knob.Msg
    | OscillatorsMixChange Knob.Msg
    | MasterVolumeChange Knob.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        updateMap childUpdate childMsg getChild reduxor msg' =
            let
                ( updatedChildModel, childCmd ) =
                    childUpdate childMsg (getChild model)
            in
                ( reduxor updatedChildModel model
                , Cmd.map msg' childCmd
                )
    in
        case msg of
            MasterVolumeChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .masterVolumeKnob
                    setMasterVolume
                    MasterVolumeChange

            OscillatorsMixChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillatorsMixKnob
                    setOscillatorsMix
                    OscillatorsMixChange

            Oscillator2SemitoneChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator2SemitoneKnob
                    setOscillator2Semitone
                    Oscillator2SemitoneChange

            Oscillator2DetuneChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator2DetuneKnob
                    setOscillator2Detune
                    Oscillator2DetuneChange

            FMAmountChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .fmAmountKnob
                    setFmAmount
                    FMAmountChange

            PulseWidthChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .pulseWidthKnob
                    setPulseWidth
                    PulseWidthChange

            Oscillator1WaveformChange waveform ->
                ( setOscillator1Waveform model waveform
                , toString waveform |> oscillator1WaveformPort
                )

            Oscillator2WaveformChange waveform ->
                ( setOscillator2Waveform model waveform
                , toString waveform |> oscillator2WaveformPort
                )


setFmAmount : Knob.Model -> Model -> Model
setFmAmount knobModel model =
    { model | fmAmountKnob = knobModel }


setPulseWidth : Knob.Model -> Model -> Model
setPulseWidth knobModel model =
    { model | oscillator2DetuneKnob = knobModel }


setOscillator2Detune : Knob.Model -> Model -> Model
setOscillator2Detune knobModel model =
    { model | oscillator2DetuneKnob = knobModel }


setOscillator2Semitone : Knob.Model -> Model -> Model
setOscillator2Semitone knobModel model =
    { model | oscillator2SemitoneKnob = knobModel }


setMasterVolume : Knob.Model -> Model -> Model
setMasterVolume knobModel model =
    { model | masterVolumeKnob = knobModel }


setOscillatorsMix : Knob.Model -> Model -> Model
setOscillatorsMix knobModel model =
    { model | oscillatorsMixKnob = knobModel }


setOscillator1Waveform : Model -> OscillatorWaveform -> Model
setOscillator1Waveform model waveform =
    { model | oscillator1Waveform = waveform }


setOscillator2Waveform : Model -> OscillatorWaveform -> Model
setOscillator2Waveform model waveform =
    { model | oscillator2Waveform = waveform }



-- VIEW


nordKnob :
    (Knob.Msg -> a)
    -> (Int -> Cmd Knob.Msg)
    -> Knob.Model
    -> String
    -> Html a
nordKnob op cmd model label =
    div [ class "knob" ]
        [ Knob.knob op cmd model
        , div [ class "knob__label" ] [ text label ]
        ]


section : String -> List (Html a) -> Html a
section title content =
    div [ class "section" ]
        [ div [ class "section__title" ]
            [ text title ]
        , div [ class "section__content" ] content
        ]


column : List (Html a) -> Html a
column content =
    div [ class "panel__column" ] content


amplifier : Model -> Html Msg
amplifier model =
    let
        knob =
            nordKnob (always MasterVolumeChange) (always Cmd.none)
    in
        section "amplifier"
            [ --knob model.ampAttackKnob "attack"
              --, knob model.ampDecayKnob "decay"
              --, knob model.ampSustainKnob "sustain"
              --, knob model.ampReleaseKnob "release"
              --,
              nordKnob MasterVolumeChange
                masterVolumePort
                model.masterVolumeKnob
                "gain"
            ]


filter : Model -> Html Msg
filter model =
    let
        knob =
            nordKnob (always MasterVolumeChange) (always Cmd.none)
    in
        section "filter" []



--[ knob model.filterAttackKnob "attack"
--, knob model.filterDecayKnob "decay"
--, knob model.filterSustainKnob "sustain"
--, knob model.filterReleaseKnob "release"
--]


oscillators : Model -> Html Msg
oscillators model =
    section "oscillators"
        [ oscillator1Waveform model Oscillator1WaveformChange
        , oscillator2Waveform model Oscillator2WaveformChange
        , nordKnob OscillatorsMixChange
            oscillatorsBalancePort
            model.oscillatorsMixKnob
            "mix"
        , nordKnob Oscillator2SemitoneChange
            oscillator2SemitonePort
            model.oscillator2SemitoneKnob
            "semitone"
        , nordKnob Oscillator2DetuneChange
            oscillator2DetunePort
            model.oscillator2DetuneKnob
            "detune"
        , nordKnob FMAmountChange fmAmountPort model.fmAmountKnob "FM"
        , nordKnob PulseWidthChange pulseWidthPort model.pulseWidthKnob "PW"
        ]


waveformSelector :
    List OscillatorWaveform
    -> (Model -> OscillatorWaveform)
    -> Model
    -> (OscillatorWaveform -> Msg)
    -> Html Msg
waveformSelector waveforms getter model msg =
    div []
        <| List.map
            (\waveform ->
                let
                    isSelected =
                        getter model == waveform
                in
                    label []
                        [ input
                            [ type' "radio"
                            , checked isSelected
                            , onCheck <| always <| msg waveform
                            ]
                            []
                        , waveform |> toString |> text
                        ]
            )
            waveforms


oscillator1Waveform : Model -> (OscillatorWaveform -> Msg) -> Html Msg
oscillator1Waveform =
    waveformSelector [ Sawtooth, Sine, Triangle, Square ]
        .oscillator1Waveform


oscillator2Waveform : Model -> (OscillatorWaveform -> Msg) -> Html Msg
oscillator2Waveform =
    waveformSelector [ Sawtooth, Triangle, Square ]
        .oscillator2Waveform


view : Model -> Html Msg
view model =
    div [ class "panel" ]
        [ column
            [ section "lfo1" [ text "breno" ]
            , section "lfo2" [ text "magro" ]
            , section "mod env" [ text "forest psy" ]
            ]
        , column [ oscillators model ]
        , column
            [ amplifier model
            , filter model
            ]
        ]


panel : (Msg -> a) -> Model -> Html a
panel panelMsg model =
    Html.App.map panelMsg
        <| view model
