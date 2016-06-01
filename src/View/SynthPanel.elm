module View.SynthPanel exposing (..) -- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as Json

import Update exposing (..)

synthPanel : Html Msg
synthPanel = 
    masterVolume

masterVolume : Html Msg
masterVolume = 
    div
        []
        [ span 
            [] 
            [ "Volume" |> text ]
        , input 
            [ Html.Attributes.type' "range" 
            , Html.Attributes.min "0"
            , Html.Attributes.max "100"
            , Html.Attributes.value "70"
            , Html.Attributes.step "1"
            , Html.Events.on "input" (Json.succeed NoOp) 
            ]
           []

        ]


        