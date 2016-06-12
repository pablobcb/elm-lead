module View.Panel exposing (..)

-- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (..)
import Ports exposing (..)
import Knob exposing (..)
import Model.Model as Model exposing (..)


nordKnob :
    (Knob.Msg -> a)
    -> (Int -> Cmd Knob.Msg)
    -> Knob.Model
    -> String
    -> Html a
nordKnob op cmd model label =
    div [ class "knob" ]
        [ knob op cmd model
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


panel : Model.Model -> Html Msg.Msg
panel model =
    div [ class "panel" ]
        [ column
            [ section "lfo1" [ text "breno" ]
            , section "lfo2" [ text "magro" ]
            , section "mod env" [ text "forest psy" ]
            ]
        , column
            [ oscillators model ]
        , column
            [ amplifier model
            , filter model
            ]
        ]


amplifier : Model.Model -> Html Msg.Msg
amplifier model =
    let
        knob = nordKnob (always NoOp) (always Cmd.none)
    in
        section "amplifier"
            [ knob model.ampAttackKnob "attack"
            , knob model.ampDecayKnob "decay"
            , knob model.ampSustainKnob "sustain"
            , knob model.ampReleaseKnob "release"
            , nordKnob MasterVolumeChange
                masterVolumePort model.masterVolumeKnob "gain"
            ]


filter : Model.Model -> Html Msg.Msg
filter model =
    let
        knob = nordKnob (always NoOp) (always Cmd.none)
    in
        section "filter"
            [ knob model.filterAttackKnob "attack"
            , knob model.filterDecayKnob "decay"
            , knob model.filterSustainKnob "sustain"
            , knob model.filterReleaseKnob "release"
            ]


oscillators : Model.Model -> Html Msg.Msg
oscillators model =
    section "oscillators"
        [ oscillator1Waveform model Oscillator1WaveformChange
        , oscillator2Waveform model Oscillator2WaveformChange
        , nordKnob OscillatorsMixChange
            oscillatorsBalancePort model.oscillatorsMixKnob "mix"
        , nordKnob Oscillator2SemitoneChange
            oscillator2SemitonePort model.oscillator2SemitoneKnob "semitone"
        , nordKnob Oscillator2DetuneChange
            oscillator2DetunePort model.oscillator2DetuneKnob "detune"
        , nordKnob FMAmountChange fmAmountPort model.fmAmountKnob "FM"
        , nordKnob PulseWidthChange pulseWidthPort model.pulseWidthKnob "PW"
        ]


waveformSelector :
    List OscillatorWaveform
    -> (Model.Model -> OscillatorWaveform)
    -> Model.Model
    -> (OscillatorWaveform -> Msg.Msg)
    -> Html Msg.Msg
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


oscillator1Waveform :
    Model.Model
    -> (OscillatorWaveform
    -> Msg.Msg)
    -> Html Msg.Msg
oscillator1Waveform =
    waveformSelector [ Sawtooth, Sine, Triangle, Square ] .oscillator1Waveform


oscillator2Waveform : Model.Model -> (OscillatorWaveform -> Msg.Msg) -> Html Msg.Msg
oscillator2Waveform =
    waveformSelector [ Sawtooth, Triangle, Square ] .oscillator2Waveform
