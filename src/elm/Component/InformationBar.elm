module Component.InformationBar exposing (informationBar)

import Html exposing (Html, div, a)
import Html.Attributes exposing (class, href)
import Main.Model as Model exposing (Model)
import Container.OnScreenKeyboard.Update as KbdUpdate
import Main.Update as Update exposing (Msg)
import Component.Incrementer as Incrementer


informationBar : Model -> Html Update.Msg
informationBar model =
    let
        midiIndicatorClass =
            "midi-indicator__status midi-indicator__status--"
                ++ (if not model.midiSupport then
                        "not-supported"
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
            [ Incrementer.incrementer Incrementer.Octave
                (" C" ++ (toString model.onScreenKeyboard.octave))
                (Update.OnScreenKeyboardMsg KbdUpdate.OctaveDown)
                (Update.OnScreenKeyboardMsg KbdUpdate.OctaveUp)
            , Incrementer.incrementer Incrementer.Velocity
                ((toString model.onScreenKeyboard.velocity))
                (Update.OnScreenKeyboardMsg KbdUpdate.VelocityDown)
                (Update.OnScreenKeyboardMsg KbdUpdate.VelocityUp)
            , Incrementer.incrementer Incrementer.Patch
                ((toString model.presetId) ++ "  " ++ model.presetName)
                Update.PreviousPreset
                Update.NextPreset
            , div [ class "midi-indicator" ]
                [ div [ class blinkerClass ] []
                , div [ class midiIndicatorClass ] []
                ]
            , a
                [ class "information-bar__gh-link"
                , href "https://github.com/pablobcb/elm-lead"
                ]
                []
            ]
