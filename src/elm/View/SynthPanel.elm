module View.SynthPanel exposing (..)

-- where

import String exposing (toFloat)
import Knob exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Update exposing (..)
import Msg exposing (..)
import Model.Model as Model exposing (..)
import Ports exposing (..)


synthPanel : Model.Model -> Html Msg.Msg
synthPanel model =
    div [ class "synth-panel" ]
        [ panelLeftSection model
        , oscillators model
        , panelRightSection model
        ]


panelLeftSection : Model.Model -> Html Msg.Msg
panelLeftSection model =
    div [ class "synth-panel panel-left-section" ]
        [ span [] [ text "master level" ]
        , knob MasterVolumeChange masterVolumePort model.masterVolumeKnob
        ]


panelRightSection : Model.Model -> Html Msg.Msg
panelRightSection model =
    div [ class "synth-panel panel-right-section" ]
        [ div []
            [ span []
                [ "Breno" |> text ]
            ]
        ]


withLabel : String -> Html a -> Html a
withLabel txt elem =
    div [] [ span [] [ text txt ], elem ]


oscillators : Model.Model -> Html Msg.Msg
oscillators model =
    div [ class "synth-panel panel-middle-section oscillators" ]
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
