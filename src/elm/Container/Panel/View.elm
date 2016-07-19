module Container.Panel.View exposing (panel)

-- where

import Component.Knob as Knob
import Component.Switch as Switch
import Component.OptionPicker as OptionPicker
import Html exposing (Html, div, span, text, table, tr, td)
import Html.Attributes exposing (class)
import Html.App
import Container.Panel.Model as Model exposing (Model)
import Container.Panel.Update as Update exposing (Msg)


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
                Knob.knob Update.KnobMsg knobModel


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
    div [ class "panel-controls__column" ] content


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

lfo1 : Model -> Html Msg
lfo1 model =
    section WithoutBevel
        "lfo 1"
        [ nordKnob model Knob.Lfo1Rate
        , OptionPicker.optionPicker "Destination"
            Update.Lfo1DestinationChange
            model.lfo1DestinationBtn
        , OptionPicker.optionPicker "Waveform"
            Update.Lfo1WaveformChange
            model.lfo1WaveformBtn
        , nordKnob model Knob.Lfo1Amount
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
            Update.FilterTypeChange
            model.filterTypeBtn
        , nordKnob model Knob.FilterCutoff
          -- frequency
        , nordKnob model Knob.FilterQ
          -- resonance
        , nordKnob model Knob.FilterEnvelopeAmount
        , Switch.switch "distortion"
            Update.OverdriveToggle
            model.overdriveSwitch
        ]


osc1 : Model -> Html Msg
osc1 model =
    div [ class "oscillators__osc1" ]
        [ OptionPicker.optionPicker "Waveform"
            Update.Osc1WaveformChange
            model.osc1WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 1" ]
        , nordKnob model Knob.FM
        ]


osc2 : Model -> Html Msg
osc2 model =
    div [ class "oscillators__osc2" ]
        [ nordKnob model Knob.Osc2Semitone
        , OptionPicker.optionPicker "Waveform"
            Update.Osc2WaveformChange
            model.osc2WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 2" ]
        , nordKnob model Knob.Osc2Detune
        , Switch.switch "kbd track"
            Update.Osc2KbdTrackToggle
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
    div [ class "panel-controls" ]
        [ column [ lfo1 model ]
        , column [ oscillatorSection model ]
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
        hotKeys = [ "Z" , "X" , "C" , "V" , "A" , "W" , "S" , "E" , "D" , "F"
            , "T" , "G" , "Y" , "H" , "U" , "J" , "K" , "O" , "L" , "P" ]

        instructions =
            [ "octave down", "octave up", "velocity down", "velocity up" ]
                ++ (List.map ((++) "play ")
                        [ "C" , "C#" , "D" , "D#" , "E" , "F"
                        , "F#" , "G" , "G#" , "A" , "A#" , "B"
                        , "C 8va" , "C# 8va" , "D 8va" , "D# 8va"
                        ]
                   )
    in
        div [ class "panel-controls__instructions" ]
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
