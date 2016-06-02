module View.SynthPanel exposing (..) -- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as Json

import Update exposing (..)
import Msg exposing (..)

synthPanel : Html Msg
synthPanel = 
    div
        []
        [ masterVolume
        , oscillatorsBalance
        , oscillator1Detune
        , oscillator2Detune
        ]

masterVolume : Html Msg
masterVolume = 
    div
        []
        [ span 
            [] 
            [ "master level" |> text ]
        , input 
            [ Html.Attributes.type' "range" 
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , Html.Attributes.value "70"
            , Html.Attributes.step "1"
            , Html.Events.onInput MasterVolumeChange
            ]
           []

        ]

oscillator1Detune : Html Msg
oscillator1Detune =
    div
        []
        [ span 
            [] 
            [ "Oscillator 1 Detune" |> text ]
        , input 
            [ Html.Attributes.type' "range" 
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , Html.Attributes.value "0"
            , Html.Attributes.step "1"
            , Html.Events.onInput Oscillator1DetuneChange
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
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , Html.Attributes.value "0"
            , Html.Attributes.step "1"
            , Html.Events.onInput Oscillator2DetuneChange
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
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , Html.Attributes.value "50"
            , Html.Attributes.step "1"
            , Html.Events.onInput OscillatorsBalanceChange
            ]
           []

        ]

        