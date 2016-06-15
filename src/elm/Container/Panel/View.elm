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


nordKnob :
    (Knob.Msg -> a)
    -> (Int -> Cmd Knob.Msg)
    -> Knob.Model
    -> String
    -> Html a
nordKnob op cmd model label =
    div [ class "knob" ]
        [ Knob.knob op cmd model
        , div [ class "knob__label" ] [ text label ]
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
    let
        knob =
            nordKnob (always MasterVolumeChange) (always Cmd.none)
    in
        section "amplifier"
            [ --knob model.ampAttackKnob "attack"
              --, knob model.ampDecayKnob "decay"
              --, knob model.ampSustainKnob "sustain"
              --, knob model.ampReleaseKnob "release"
              --,
              nordKnob MasterVolumeChange
                masterVolumePort
                model.masterVolumeKnob
                "gain"
            ]


filter : Model -> Html Msg
filter model =
    let
        knob =
            nordKnob (always MasterVolumeChange) (always Cmd.none)
    in
        section "filter" []



--[ knob model.filterAttackKnob "attack"
--, knob model.filterDecayKnob "decay"
--, knob model.filterSustainKnob "sustain"
--, knob model.filterReleaseKnob "release"
--]


osc1 : Model -> Html Msg
osc1 model =
    div [ class "osc1" ]
        [ Button.nordButton Oscillator1WaveformChange
            oscillator1WaveformPort
            model.oscillator1WaveformBtn
        , span [ class "osc-label" ] [ text "OSC 1" ]
        , nordKnob FMAmountChange
            fmAmountPort
            model.fmAmountKnob
            "FM"
        ]


osc2 : Model -> Html Msg
osc2 model =
    div [ class "osc2" ]
        [ Button.nordButton Oscillator2WaveformChange
            oscillator2WaveformPort
            model.oscillator2WaveformBtn
        , span [ class "osc-label" ] [ text "OSC 2" ]
        , nordKnob Oscillator2SemitoneChange
            oscillator2SemitonePort
            model.oscillator2SemitoneKnob
            "semitone"
        , nordKnob Oscillator2DetuneChange
            oscillator2DetunePort
            model.oscillator2DetuneKnob
            "detune"
        ]


oscillatorSection : Model -> Html Msg
oscillatorSection model =
    section "oscillators"
        [ div [ class "oscillators" ]
            [ osc1 model, osc2 model ]
        , div [ class "oscillators-extra" ]
            [ nordKnob PulseWidthChange
                pulseWidthPort
                model.pulseWidthKnob
                "PW"
            , nordKnob OscillatorsMixChange
                oscillatorsBalancePort
                model.oscillatorsMixKnob
                "mix"
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "panel" ]
        [ column
            [ section "lfo1" [ text "breno" ]
            , section "lfo2" [ text "magro" ]
            , section "mod env" [ text "forest psy" ]
            ]
        , column [ oscillatorSection model ]
        , column
            [ amplifier model
            , filter model
            ]
        ]


panel : (Msg -> a) -> Model -> Html a
panel panelMsg model =
    Html.App.map panelMsg
        <| view model
