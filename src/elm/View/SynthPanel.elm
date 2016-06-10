module View.SynthPanel exposing (..)

-- where

import String exposing (toFloat)
import Knob exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.App exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Update exposing (..)
import Msg exposing (..)
import Model.Model as Model exposing (..)
import Ports exposing (..)


oscillator1WaveformRadio : OscillatorWaveform -> String -> Model.Model -> Html Msg.Msg
oscillator1WaveformRadio waveform name model =
    let
        isSelected =
            model.oscillator1Waveform == waveform
    in
        label []
            [ input
                [ type' "radio"
                , checked isSelected
                , onCheck (\_ -> Oscillator1WaveformChange waveform)
                ]
                []
            , text name
            ]


oscillator2WaveformRadio : OscillatorWaveform -> String -> Model.Model -> Html Msg.Msg
oscillator2WaveformRadio waveform name model =
    let
        isSelected =
            model.oscillator2Waveform == waveform
    in
        label []
            [ input
                [ type' "radio"
                , checked isSelected
                , onCheck (\_ -> Oscillator2WaveformChange waveform)
                ]
                []
            , text name
            ]


unsafeToFloat : String -> Float
unsafeToFloat value =
    case String.toFloat value of
        Ok value' ->
            value'

        Err err ->
            Debug.crash err


synthPanel : Model.Model -> Html Msg.Msg
synthPanel model =
    div [ class "synth-panel" ]
        [ panelLeftSection model
        , panelMiddleSection model
        , panelRightSection model
        ]


panelLeftSection : Model.Model -> Html Msg.Msg
panelLeftSection model =
    div [ class "synth-panel panel-left-section" ]
        [ span [] [ text "master level" ]
        , knob MasterVolumeChange (Basics.toFloat >> masterVolumePort) model.masterVolumeKnob
        ]


oscillatorsBalance : Model.Model -> Html Msg.Msg
oscillatorsBalance model =
    div []
        [ span []
            [ "Oscillators Balance" |> text ]
        , knob OscillatorsMixChange (Basics.toFloat >> oscillatorsBalancePort) model.oscillatorsMix
        ]


panelMiddleSection : Model.Model -> Html Msg.Msg
panelMiddleSection model =
    div [ class "synth-panel panel-middle-section" ]
        [ oscillators model ]


panelRightSection : Model.Model -> Html Msg.Msg
panelRightSection model =
    div [ class "synth-panel panel-right-section" ]
        [ div []
            [ span []
                [ "Breno" |> text ]
            , input
                [ Html.Attributes.type' "range"
                , Html.Attributes.min "0"
                , Html.Attributes.max "100"
                , Html.Attributes.value "0"
                , Html.Attributes.step "1"
                , Html.Events.onInput (\_ -> NoOp)
                ]
                []
            ]
        ]


oscillators : Model.Model -> Html Msg.Msg
oscillators model =
    div [ class "oscillators" ]
        [ oscillatorsBalance model
        , oscillator1Waveform model
        , oscillator2Waveform model
        , oscillator2Semitone
        , oscillator2Detune
        , fmAmount
        , pulseWidth
        ]



--masterVolume : Html msg
--masterVolume =
--    div [ class "master-volume" ]
--        [ span []
--            [ "master level" |> text ]
--        , input
--            [ Html.Attributes.type' "range"
--            , Html.Attributes.min "0"
--            , Html.Attributes.max "100"
--            , Html.Attributes.value "10"
--            , Html.Attributes.step "1"
--            , Html.Events.onInput <| unsafeToFloat >> MasterVolumeChange
--            ]
--            []
--        ]


oscillator2Semitone : Html Msg.Msg
oscillator2Semitone =
    div []
        [ span []
            [ "Oscillator 2 Semitone" |> text ]
        , input
            [ Html.Attributes.type' "range"
            , Html.Attributes.min "-60"
            , Html.Attributes.max "60"
            , Html.Attributes.value "0"
            , Html.Attributes.step "1"
            , Html.Events.onInput <| unsafeToFloat >> Oscillator2SemitoneChange
            ]
            []
        ]


oscillator2Detune : Html Msg.Msg
oscillator2Detune =
    div []
        [ span []
            [ "Oscillator 2 Detune" |> text ]
        , input
            [ Html.Attributes.type' "range"
            , Html.Attributes.min "-100"
            , Html.Attributes.max "100"
            , Html.Attributes.value "0"
            , Html.Attributes.step "1"
            , Html.Events.onInput <| unsafeToFloat >> Oscillator2DetuneChange
            ]
            []
        ]


fmAmount : Html Msg.Msg
fmAmount =
    div []
        [ span []
            [ "FM" |> text ]
        , input
            [ Html.Attributes.type' "range"
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , Html.Attributes.value "0"
            , Html.Attributes.step "1"
            , Html.Events.onInput <| unsafeToFloat >> FMAmountChange
            ]
            []
        ]


pulseWidth : Html Msg.Msg
pulseWidth =
    div []
        [ span []
            [ "PW" |> text ]
        , input
            [ Html.Attributes.type' "range"
            , Html.Attributes.min "50"
            , Html.Attributes.max "99"
            , Html.Attributes.value "50"
            , Html.Attributes.step "1"
            , Html.Events.onInput <| unsafeToFloat >> PulseWidthChange
            ]
            []
        ]


oscillator1Waveform : Model.Model -> Html Msg.Msg
oscillator1Waveform model =
    div []
        [ span []
            [ text "OSC1 Wave" ]
        , oscillator1WaveformRadio Sawtooth "sawtooth" model
        , oscillator1WaveformRadio Triangle "triangle" model
        , oscillator1WaveformRadio Sine "sine" model
        , oscillator1WaveformRadio Square "square" model
        ]


oscillator2Waveform : Model.Model -> Html Msg.Msg
oscillator2Waveform model =
    div []
        [ span []
            [ text "OSC2 Wave" ]
        , oscillator2WaveformRadio Sawtooth "sawtooth" model
        , oscillator2WaveformRadio Triangle "triangle" model
        , oscillator2WaveformRadio Square "square" model
        ]
