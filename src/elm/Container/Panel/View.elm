module Container.Panel.View exposing (..)

-- where

import Component.Knob as Knob
import Component.NordButton as Button
import Port exposing (..)
import Html exposing (..)
import Dict exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (map)
import Container.Panel.Model as Model exposing (..)
import Container.Panel.Update as Update exposing (..)


--nordKnob : (Knob.Msg -> a) -> Knob.Model -> String -> Html a


nordKnob model knobInstance labelTxt =
    case Dict.get (toString knobInstance) model.knobs of
        Nothing ->
            Debug.crash "inexistent knob identifier"

        Just knobModel ->
            div [ class "knob" ]
                [ Knob.knob KnobMsg knobModel
                , div [ class "pannel__label" ] [ text labelTxt ]
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
    section "amplifier"
        [ nordKnob model AmpGain "gain" ]


filter : Model -> Html Msg
filter model =
    section "filter"
        [ div [ class "filter" ]
            [ nordKnob model FilterCutoff "Frequency"
            , nordKnob model FilterQ "Resonance"
            , Button.nordButton "Filter Type"
                FilterTypeChange
                filterTypePort
                model.filterTypeBtn
            ]
        ]



--[ knob model.filterAttackKnob "attack"
--, knob model.filterDecayKnob "decay"
--, knob model.filterSustainKnob "sustain"
--, knob model.filterReleaseKnob "release"
--]


osc1 : Model -> Html Msg
osc1 model =
    div [ class "oscillators__osc1" ]
        [ Button.nordButton "Waveform"
            Oscillator1WaveformChange
            oscillator1WaveformPort
            model.oscillator1WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 1" ]
        , nordKnob model FM "FM"
        ]


osc2 : Model -> Html Msg
osc2 model =
    div [ class "osc2" ]
        [ Button.nordButton "Waveform"
            Oscillator2WaveformChange
            oscillator2WaveformPort
            model.oscillator2WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 2" ]
        , nordKnob model Osc2Semitone "semitone"
        , nordKnob model Osc2Detune "detune"
        ]


oscillatorSection : Model -> Html Msg
oscillatorSection model =
    section "oscillators"
        [ div [ class "oscillators" ]
            [ osc1 model, osc2 model ]
        , div [ class "oscillators__extra" ]
            [ nordKnob model PW
                "PW"
            , nordKnob model OscMix
                "mix"
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "panel" ]
        [ --column
          --  [ section "lfo1" [ text "breno" ]
          --  , section "lfo2" [ text "magro" ]
          --  , section "mod env" [ text "forest psy" ]
          --  ],
          column [ oscillatorSection model ]
        , column
            [ amplifier model
            , filter model
            ]
        , instructions
        ]


panel : (Msg -> a) -> Model -> Html a
panel panelMsg model =
    Html.App.map panelMsg
        <| view model



--TODO generate this in smart way
--list of pair instruction text and map


instructions : Html a
instructions =
    div [ class "pannel-instructions" ]
        [ span [ class "instructions__title" ] [ text "INSTRUCTIONS" ]
        , table [ class "instructions" ]
            [ tr [ class "instructions__entry" ]
                [ td [] [ text "Z" ]
                , td [ class "instructions__label" ] [ text "octave down" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "X" ]
                , td [ class "instructions__label" ] [ text "octave up" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "C" ]
                , td [ class "instructions__label" ] [ text "velocity down" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "V" ]
                , td [ class "instructions__label" ] [ text "velocity up" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "A" ]
                , td [ class "instructions__label" ] [ text "play C" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "W" ]
                , td [ class "instructions__label" ] [ text "play C#" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "S" ]
                , td [ class "instructions__label" ] [ text "play D" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "E" ]
                , td [ class "instructions__label" ] [ text "play D#" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "D" ]
                , td [ class "instructions__label" ] [ text "play E" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "F" ]
                , td [ class "instructions__label" ] [ text "play F" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "T" ]
                , td [ class "instructions__label" ] [ text "play F#" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "G" ]
                , td [ class "instructions__label" ] [ text "play G" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "Y" ]
                , td [ class "instructions__label" ] [ text "play G#" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "H" ]
                , td [ class "instructions__label" ] [ text "play A" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "U" ]
                , td [ class "instructions__label" ] [ text "play A#" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "P" ]
                , td [ class "instructions__label" ] [ text "play B" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "J" ]
                , td [ class "instructions__label" ] [ text "play C 8va" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "K" ]
                , td [ class "instructions__label" ] [ text "play C# 8va" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "O" ]
                , td [ class "instructions__label" ] [ text "play D 8va" ]
                ]
            , tr [ class "instructions__entry" ]
                [ td [] [ text "L" ]
                , td [ class "instructions__label" ] [ text "play D# 8va" ]
                ]
            ]
        ]
