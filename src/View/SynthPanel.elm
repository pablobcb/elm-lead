module View.SynthPanel exposing (..) -- where

import String exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as Json

import Update exposing (..)
import Msg exposing (..)

import Model.Model exposing (..)

oscillator1WaveformRadio : OscillatorWaveform -> String -> Model -> Html Msg
oscillator1WaveformRadio waveform name model =
  let
    isSelected =
      model.oscillator1Waveform == waveform
  in
    label []
      [ input 
        [ type' "radio"
        , checked isSelected
        , onCheck (\_ -> Oscillator1WaveformChange waveform) ] 
        []
      , text name
      ]

oscillator2WaveformRadio : OscillatorWaveform -> String -> Model -> Html Msg
oscillator2WaveformRadio waveform name model =
  let
    isSelected =
      model.oscillator2Waveform == waveform
  in
    label []
      [ input 
        [ type' "radio"
        , checked isSelected
        , onCheck (\_ -> Oscillator2WaveformChange waveform) ] 
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

synthPanel : Model -> Html Msg
synthPanel model = 
  div
    [ class "synth-panel" ]
    [ panelLeftSection model
    , panelMiddleSection model
    , panelRightSection model
    ]

panelLeftSection : Model -> Html Msg
panelLeftSection model =
  div
    [ class "synth-panel panel-left-section" ]
    [ masterVolume ]


panelMiddleSection : Model -> Html Msg
panelMiddleSection model =
  div
    [ class "synth-panel panel-middle-section" ]
    [ oscillators model ]


panelRightSection : Model -> Html Msg
panelRightSection model =
  div
    [ class "synth-panel panel-right-section" ]
    [
      div
      []
      [ span 
          [] 
          [ "Breno" |> text ]
      , input 
          [ Html.Attributes.type' "range" 
          , Html.Attributes.min "0"
          , Html.Attributes.max "100"
          , Html.Attributes.value "0"
          , Html.Attributes.step "1"
          , Html.Events.onInput (\_->NoOp)
          ]
         []
      ]
    ]


oscillators : Model -> Html Msg
oscillators model =
  div
   [ class "oscillators" ]
   [ oscillatorsBalance
   , oscillator1Waveform model
   , oscillator2Waveform model
   , oscillator2Semitone
   , oscillator2Detune
   , fmAmount
   , pulseWidth
   ]


masterVolume : Html Msg
masterVolume = 
  div
    [ class "master-volume"]
    [ span 
        [] 
        [ "master level" |> text ]
    , input
        [ Html.Attributes.type' "range" 
        , Html.Attributes.min "0"
        , Html.Attributes.max "100"
        , Html.Attributes.value "10"
        , Html.Attributes.step "1"
        , Html.Events.onInput <| unsafeToFloat >> MasterVolumeChange
        ]
        []
    ]

oscillator2Semitone : Html Msg
oscillator2Semitone =
  div
      []
      [ span 
          [] 
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

oscillator2Detune : Html Msg
oscillator2Detune =
  div
      []
      [ span 
          [] 
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

oscillatorsBalance : Html Msg
oscillatorsBalance =
  div
      []
      [ span 
          [] 
          [ "Oscillators Balance" |> text ]
      , input 
          [ Html.Attributes.type' "range"
          , Html.Attributes.min "-50"
          , Html.Attributes.max "50"
          , Html.Attributes.value "0"
          , Html.Attributes.step "1"
          , Html.Events.onInput <| unsafeToFloat >> OscillatorsBalanceChange
          ]
         []
      ]

fmAmount : Html Msg
fmAmount =
  div
      []
      [ span 
          [] 
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

pulseWidth : Html Msg
pulseWidth =
  div
      []
      [ span 
          [] 
          [ "PW" |> text ]
      , input 
          [ Html.Attributes.type' "range"
          , Html.Attributes.min "1"
          , Html.Attributes.max "99"
          , Html.Attributes.value "50"
          , Html.Attributes.step "1"
          , Html.Events.onInput <| unsafeToFloat >> PulseWidthChange
          ]
         []
      ]

oscillator1Waveform : Model -> Html Msg
oscillator1Waveform model =
  div []
    [ span 
      [] 
      [text "OSC1 Wave"]
    , oscillator1WaveformRadio Sawtooth "sawtooth" model
    , oscillator1WaveformRadio Triangle "triangle" model
    , oscillator1WaveformRadio Sine "sine" model
    , oscillator1WaveformRadio Square "square" model
    ]

oscillator2Waveform : Model -> Html Msg
oscillator2Waveform model =
  div []
    [ span 
      [] 
      [text "OSC2 Wave"]
    , oscillator2WaveformRadio Sawtooth "sawtooth" model
    , oscillator2WaveformRadio Triangle "triangle" model
    , oscillator2WaveformRadio Square "square" model
    ]

