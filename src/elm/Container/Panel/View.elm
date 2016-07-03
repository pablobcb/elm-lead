module Container.Panel.View exposing (..)

-- where

import Component.Knob as Knob
import Component.Switch as Switch
import Component.OptionPicker as OptionPicker
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (map)
import Container.Panel.Model as Model exposing (..)
import Container.Panel.Update as Update exposing (..)


type Bevel
    = WithBevel
    | WithoutBevel


nordKnob : Model -> Knob.KnobInstance -> Html Msg
nordKnob model knobInstance =
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
                Knob.knob KnobMsg knobModel


section : Bevel -> String -> List (Html a) -> Html a
section bevelType title content =
    let
        sectionClass =
            case bevelType of
                WithBevel ->
                    "section section--with-bevel"

                WithoutBevel ->
                    "section"
    in
        div [ class sectionClass ]
            [ div [ class "section__title" ]
                [ text title ]
            , div [ class "section__content" ] content
            ]


column : List (Html a) -> Html a
column content =
    div [ class "panel__column" ] content


amplifier : Model -> Html Msg
amplifier model =
    section WithoutBevel
        "amplifier"
        [ nordKnob model Knob.AmpAttack
        , nordKnob model Knob.AmpDecay
        , nordKnob model Knob.AmpSustain
        , nordKnob model Knob.AmpRelease
        , nordKnob model Knob.AmpGain
        ]


filter : Model -> Html Msg
filter model =
    section WithoutBevel
        "filter"
        [ nordKnob model Knob.FilterAttack
        , nordKnob model Knob.FilterDecay
        , nordKnob model Knob.FilterSustain
        , nordKnob model Knob.FilterRelease
        , OptionPicker.optionPicker "Filter Type"
            FilterTypeChange
            model.filterTypeBtn
        , nordKnob model Knob.FilterCutoff -- frequency
        , nordKnob model Knob.FilterQ      -- resonance
        , nordKnob model Knob.FilterEnvelopeAmount
        , Switch.switch "distortion"
            FilterDistortionToggle
            model.filterDistortionSwitch
        ]


osc1 : Model -> Html Msg
osc1 model =
    div [ class "oscillators__osc1" ]
        [ OptionPicker.optionPicker "Waveform"
            Osc1WaveformChange
            model.osc1WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 1" ]
        , nordKnob model Knob.FM
        ]


osc2 : Model -> Html Msg
osc2 model =
    div [ class "oscillators__osc2" ]
        [ nordKnob model Knob.Osc2Semitone
        , OptionPicker.optionPicker "Waveform"
            Osc2WaveformChange
            model.osc2WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 2" ]
        , nordKnob model Knob.Osc2Detune
        , Switch.switch "kbd track"
            Osc2KbdTrackToggle
            model.osc2KbdTrackSwitch
        ]


oscillatorSection : Model -> Html Msg
oscillatorSection model =
    section WithBevel
        "oscillators"
        [ osc1 model
        , osc2 model
        , div [ class "oscillators__extra" ]
            [ nordKnob model Knob.PW
            , nordKnob model Knob.OscMix
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
        div [ class "instructions-container" ]
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
