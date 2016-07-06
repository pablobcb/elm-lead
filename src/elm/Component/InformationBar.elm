module Component.InformationBar exposing (informationBar)

import Html.Attributes exposing (..)
import Html exposing (..)
import Main.Model as Model exposing (..)
import Container.OnScreenKeyboard.Update as KbdUpdate exposing (..)
import Main.Update as Update exposing (..)
import Component.Incrementer as Incrementer


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
            [ Incrementer.incrementer Incrementer.Octave
                (" C" ++ (toString model.onScreenKeyboard.octave))
                (OnScreenKeyboardMsg KbdUpdate.OctaveUp)
                (OnScreenKeyboardMsg KbdUpdate.OctaveDown)
            , Incrementer.incrementer Incrementer.Velocity
                ((toString model.onScreenKeyboard.velocity))
                (OnScreenKeyboardMsg KbdUpdate.VelocityUp)
                (OnScreenKeyboardMsg KbdUpdate.VelocityDown)
            , Incrementer.incrementer Incrementer.Patch
                model.presetName
                (OnScreenKeyboardMsg KbdUpdate.OctaveUp)
                (OnScreenKeyboardMsg KbdUpdate.OctaveDown)
              --, a
              --    [ class "information-bar__gh-link"
              --    , href "https://github.com/pablobcb/elm-lead"
              --    ]
              --    []

            , div [ class "midi-indicator" ]
                [ div [ class blinkerClass ] []
                , div [ class midiIndicatorClass ] []
                ]
            ]