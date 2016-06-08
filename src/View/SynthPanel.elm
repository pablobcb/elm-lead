module View.SynthPanel exposing (..) -- where

import String exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as Json

import Update exposing (..)
import Msg exposing (..)


unsafeToFloat : String -> Float
unsafeToFloat value =
  case String.toFloat value of
    Ok value' ->
      value'

    Err err ->
      Debug.crash err

synthPanel : Html Msg
synthPanel = 
  div
    [ class "synth-panel" ]
    [ panelLeftSection
    , panelMiddleSection
    , panelRightSection
    ]

panelLeftSection : Html Msg
panelLeftSection =
  div
    [ class "synth-panel panel-left-section" ]
    [ masterVolume ]


panelMiddleSection : Html Msg
panelMiddleSection =
  div
    [ class "synth-panel panel-middle-section" ]
    [ oscillators ]


panelRightSection : Html Msg
panelRightSection =
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


oscillators : Html Msg
oscillators =
  div
   [ class "oscillators" ]
   [ oscillatorsBalance
   , oscillator2Semitone
   , oscillator2Detune
   , fmAmount
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
