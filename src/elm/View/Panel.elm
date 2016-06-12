module View.Panel exposing (..)

-- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (..)
import Ports exposing (..)
import Knob exposing (..)
import Model.Model as Model exposing (..)


nordKnob : (Knob.Msg -> a) -> (Int -> Cmd Knob.Msg) -> Knob.Model -> String -> Html a
nordKnob op cmd model label =
    div [ class "knob" ]
        [ knob op cmd model
        , div [ class "knob__label" ] [ text label ]
        ]


section : String -> Html a -> Html a
section title content =
    div [ class "section" ]
        [ div [ class "section__title" ]
            [ text title ]
        , div [ class "section__content" ]
            [ content ]
        ]


panel : Model.Model -> Html Msg.Msg
panel model =
    div [ class "panel" ]
        [ div [ class "modulators" ]
            [ section "lfo1" <| text "breno"
            , section "lfo2" <| text "magro"
            , section "mod env" <| text "forest psy"
            ]
        , section "oscillators" <| oscillators model
        , div [ class "ampAndFilter" ]
            [ section "amplifier" <| amplifier model
            , section "filter" <| filter model
            ]
        ]


amplifier : Model.Model -> Html Msg.Msg
amplifier model =
    div [ class "amplifier" ]
        [ nordKnob (always NoOp) (always Cmd.none) model.ampAttackKnob "attack"
        , nordKnob (always NoOp) (always Cmd.none) model.ampDecayKnob "decay"
        , nordKnob (always NoOp) (always Cmd.none) model.ampSustainKnob "sustain"
        , nordKnob (always NoOp) (always Cmd.none) model.ampReleaseKnob "release"
        , nordKnob MasterVolumeChange masterVolumePort model.masterVolumeKnob "gain"
        ]


filter : Model.Model -> Html Msg.Msg
filter model =
    div [ class "filter" ]
        [ nordKnob (always NoOp) (always Cmd.none) model.filterAttackKnob "attack"
        , nordKnob (always NoOp) (always Cmd.none) model.filterDecayKnob "decay"
        , nordKnob (always NoOp) (always Cmd.none) model.filterSustainKnob "sustain"
        , nordKnob (always NoOp) (always Cmd.none) model.filterReleaseKnob "release"
        ]


oscillators : Model.Model -> Html Msg.Msg
oscillators model =
    div [ class "oscillators" ]
        [ oscillator1Waveform model Oscillator1WaveformChange
        , oscillator2Waveform model Oscillator2WaveformChange
        , nordKnob OscillatorsMixChange oscillatorsBalancePort model.oscillatorsMixKnob "mix"
        , nordKnob Oscillator2SemitoneChange oscillator2SemitonePort model.oscillator2SemitoneKnob "semitone"
        , nordKnob Oscillator2DetuneChange oscillator2DetunePort model.oscillator2DetuneKnob "detune"
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


oscillator1Waveform : Model.Model -> (OscillatorWaveform -> Msg.Msg) -> Html Msg.Msg
oscillator1Waveform =
    waveformSelector [ Sawtooth, Sine, Triangle, Square ] .oscillator1Waveform


oscillator2Waveform : Model.Model -> (OscillatorWaveform -> Msg.Msg) -> Html Msg.Msg
oscillator2Waveform =
    waveformSelector [ Sawtooth, Triangle, Square ] .oscillator2Waveform
