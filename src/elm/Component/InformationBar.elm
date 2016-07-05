module Component.InformationBar exposing (informationBar)

import Html.Attributes exposing (..)
import Html exposing (..)
import Main.Model as Model exposing (..)
import Container.OnScreenKeyboard.Update as KbdUpdate exposing (..)
import Main.Update as Update exposing (..)
import Component.Incrementer exposing (incrementer)


informationBar : Model -> Html Update.Msg
informationBar model =
    let
        midiIndicatorClass =
            "midi-indicator__status midi-indicator__status--"
                ++ (if not model.midiSupport then
                        "not-supported"
                    else if model.searchingMidi then
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
    in
        div [ class "information-bar" ]
            [ incrementer "Octave"
                (" C" ++ (toString model.onScreenKeyboard.octave))
                (OnScreenKeyboardMsg KbdUpdate.OctaveUp)
                (OnScreenKeyboardMsg KbdUpdate.OctaveDown)
            , div [ class "midi-indicator" ]
                [ div [ class blinkerClass ] []
                , div [ class midiIndicatorClass ] []
                ]
            , incrementer "Patch"
                model.presetName
                (OnScreenKeyboardMsg KbdUpdate.OctaveUp)
                (OnScreenKeyboardMsg KbdUpdate.OctaveDown)
            , a
                [ class "information-bar__gh-link"
                , href "https://github.com/pablobcb/elm-lead"
                ]
                []
            , incrementer "Velocity"
                ((toString model.onScreenKeyboard.velocity))
                (OnScreenKeyboardMsg KbdUpdate.VelocityUp)
                (OnScreenKeyboardMsg KbdUpdate.VelocityDown)
            ]
