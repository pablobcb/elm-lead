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
        [ class "synth-panel"]
        [ masterVolume
        , oscillatorDetune
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

oscillatorDetune : Html Msg
oscillatorDetune =
    div
        []
        [ span 
            [] 
            [ "Oscillator Detune" |> text ]
        , input 
            [ Html.Attributes.type' "range" 
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , Html.Attributes.value "0"
            , Html.Attributes.step "1"
            , Html.Events.onInput OscillatorDetuneChange
            ]
           []

        ]

        