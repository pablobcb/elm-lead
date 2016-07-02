module Main.View exposing (..)

import Main.Model as Model exposing (..)
import Html.Attributes exposing (..)
import Html exposing (..)
import Container.OnScreenKeyboard.View as KbdView exposing (..)
import Container.Panel.View as PanelView exposing (..)
import Main.Update as Update exposing (..)
import Process exposing (..)


view : Model -> Html Update.Msg
view model =
    div [ class "dashboard" ]
        [ PanelView.panel PanelMsg
            model.panel
        , KbdView.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        , informationBar model
        ]


informationBar : Model -> Html Update.Msg
informationBar model =
    let
        startOctave =
            toString model.onScreenKeyboard.octave

        endOctave =
            model.onScreenKeyboard.octave + 1 |> toString

        octaveText =
            "Octave is C" ++ startOctave ++ " to C" ++ endOctave

        velocityText =
            "Velocity is " ++ (toString model.onScreenKeyboard.velocity)

        midiIndicatorClass =
            "midi-indicator__status midi-indicator__status--"
                ++ (if model.searchingMidi then
                        "scanning"
                    else if model.midiConnected then
                        "active"
                    else
                        "inactive"
                   )

        blinkerClass =
            "midi-indicator__blinker midi-indicator__blinker--"
                ++ (if model.midiMsgInLedOn then
                        "active"
                    else
                        "inactive"
                   )

        --midiMsgInLedOn
    in
        div [ class "information-bar" ]
            [ span [ class "information-bar__item" ]
                [ octaveText |> text ]
            , span [ class "information-bar__item" ] [ text velocityText ]
            , div [ class "midi-indicator" ]
                [ div [ class blinkerClass ] []
                , div [ class midiIndicatorClass ] []
                ]
            , a [ href "https://github.com/pablobcb/elm-lead" ]
                [ img [ src "gh.png", class "information-bar__gh-link" ] [] ]
            ]
