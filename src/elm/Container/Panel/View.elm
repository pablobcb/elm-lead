module Container.Panel.View exposing (..)

-- where

import Components.Knob as Knob
import Port exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (map)
import Container.Panel.Model as Model exposing (..)
import Container.Panel.Update as Update exposing (..)


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
