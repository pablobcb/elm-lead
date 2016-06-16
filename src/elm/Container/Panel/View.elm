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
import Container.Panel.View.Instructions as Instructions exposing (..)


nordKnob :
    (Knob.Msg -> a)
    -> (Int -> Cmd Knob.Msg)
    -> Knob.Model
    -> String
    -> Html a
nordKnob op cmd model label =
    div [ class "knob" ]
        [ Knob.knob op cmd model
        , div [ class "pannel__label" ] [ text label ]
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
            [ --knob model.ampAttackKnob "attack"
              --, knob model.ampDecayKnob "decay"
              --, knob model.ampSustainKnob "sustain"
              --, knob model.ampReleaseKnob "release"
              --,
              nordKnob MasterVolumeChange
                masterVolumePort
                model.ampVolumeKnob
                "gain"
            ]


filter : Model -> Html Msg
filter model =
    section "filter"
        [ div [ class "filter" ]
            [ nordKnob FilterCutoffChange
                filterCutoffPort
                model.filterCutoffKnob
                "Frequency"
            , nordKnob FilterQChange
                filterQPort
                model.filterQKnob
                "Resonance"
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
        , nordKnob FMAmountChange
            fmAmountPort
            model.oscillator1FmAmountKnob
            "FM"
        ]


osc2 : Model -> Html Msg
osc2 model =
    div [ class "osc2" ]
        [ Button.nordButton "Waveform"
            Oscillator2WaveformChange
            oscillator2WaveformPort
            model.oscillator2WaveformBtn
        , span [ class "oscillators__label" ] [ text "OSC 2" ]
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
        , div [ class "oscillators__extra" ]
            [ nordKnob PulseWidthChange
                pulseWidthPort
                model.oscillatorsPulseWidthKnob
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
        , Instructions.instructions 
        ]


panel : (Msg -> a) -> Model -> Html a
panel panelMsg model =
    Html.App.map panelMsg
        <| view model
