module View.SynthPanel exposing (..)

-- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (..)
import Ports exposing (..)
import Knob exposing (..)
import Model.Model as Model exposing (..)


withLabel : String -> Html a -> Html a
withLabel txt elem =
    div [] [ span [] [ text txt ], elem ]


synthPanel : Model.Model -> Html Msg.Msg
synthPanel model =
    div [ class "synth-panel" ]
        [ knob MasterVolumeChange masterVolumePort model.masterVolumeKnob |> withLabel "master level"
        , oscillators model
        ]


oscillators : Model.Model -> Html Msg.Msg
oscillators model =
    div [ class "synth-panel oscillators" ]
        [ knob OscillatorsMixChange oscillatorsBalancePort model.oscillatorsMixKnob |> withLabel "mix"
        , knob Oscillator2SemitoneChange oscillator2SemitonePort model.oscillator2SemitoneKnob |> withLabel "semitone"
        , knob Oscillator2DetuneChange oscillator2DetunePort model.oscillator2DetuneKnob |> withLabel "detune"
        , knob FMAmountChange fmAmountPort model.fmAmountKnob |> withLabel "FM"
        , knob PulseWidthChange pulseWidthPort model.pulseWidthKnob |> withLabel "PW"
        , oscillator1Waveform model Oscillator1WaveformChange |> withLabel "OSC1 Wave"
        , oscillator2Waveform model Oscillator2WaveformChange |> withLabel "OSC2 Wave"
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
