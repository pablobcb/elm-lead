module Container.Panel.View exposing (..)

-- where

import Component.Knob as Knob
import Component.NordButton as Button
import Port exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (map)
import Container.Panel.Model as Model exposing (..)
import Container.Panel.Update as Update exposing (..)


nordKnob : Model -> Knob.KnobInstance -> String -> Html Msg
nordKnob model knobInstance labelTxt =
    let
        knob =
            List.head
                <| List.filter (\knob' -> knob'.idKey == knobInstance)
                    model.knobs
    in
        case knob of
            Nothing ->
                Debug.crash "inexistent knob identifier"

            Just knobModel ->
                div [ class "knob" ]
                    [ Knob.knob KnobMsg knobModel
                    , div [ class "knob__label" ] [ text labelTxt ]
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
        [ div [ class "amplifier" ]
            [ nordKnob model Knob.AmpAttack "attack" 
            , nordKnob model Knob.AmpDecay "decay" 
            , nordKnob model Knob.AmpSustain "sustain"
            , nordKnob model Knob.AmpGain "gain"
            ]
        ]


filter : Model -> Html Msg
filter model =
    section "filter"
        [ div [ class "filter" ]
            [ nordKnob model Knob.FilterCutoff "Frequency"
            , nordKnob model Knob.FilterQ "Resonance"
            , Button.nordButton "Filter Type"
                FilterTypeChange
                filterTypePort
                model.filterTypeBtn
            ]
        ]


osc1 : Model -> Html Msg
osc1 model =
    div [ class "oscillators__osc1" ]
        [ Button.nordButton "Waveform"
            Oscillator1WaveformChange
            oscillator1WaveformPort
            model.oscillator1WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 1" ]
        , nordKnob model Knob.FM "FM"
        ]


osc2 : Model -> Html Msg
osc2 model =
    div [ class "osc2" ]
        [ Button.nordButton "Waveform"
            Oscillator2WaveformChange
            oscillator2WaveformPort
            model.oscillator2WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 2" ]
        , nordKnob model Knob.Osc2Semitone "semitone"
        , nordKnob model Knob.Osc2Detune "detune"
        ]


oscillatorSection : Model -> Html Msg
oscillatorSection model =
    section "oscillators"
        [ div [ class "oscillators" ]
            [ osc1 model, osc2 model ]
        , div [ class "oscillators__extra" ]
            [ nordKnob model
                Knob.PW
                "PW"
            , nordKnob model
                Knob.OscMix
                "mix"
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "panel" ]
        [ column [ oscillatorSection model ]
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


instructions : Html a
instructions =
    let
        hotKeys =
            [ "Z"
            , "X"
            , "C"
            , "V"
            , "A"
            , "W"
            , "S"
            , "E"
            , "D"
            , "F"
            , "T"
            , "G"
            , "Y"
            , "H"
            , "U"
            , "J"
            , "K"
            , "O"
            , "L"
            , "P"
            ]

        instructions =
            [ "octave down", "octave up", "velocity down", "velocity up" ]
                ++ (List.map ((++) "play ")
                        [ "C"
                        , "C#"
                        , "D"
                        , "D#"
                        , "E"
                        , "F"
                        , "F#"
                        , "G"
                        , "G#"
                        , "A"
                        , "A#"
                        , "B"
                        , "C 8va"
                        , "C# 8va"
                        , "D 8va"
                        , "D# 8va"
                        ]
                   )
    in
        div [ class "pannel-instructions" ]
            [ span [ class "instructions__title" ] [ text "INSTRUCTIONS" ]
            , table [ class "instructions" ]
                <| List.map2
                    (\hotkey instruction ->
                        tr [ class "instructions__entry" ]
                            [ td [] [ text hotkey ]
                            , td [ class "instructions__label" ] [ text instruction ]
                            ]
                    )
                    hotKeys
                    instructions
            ]
