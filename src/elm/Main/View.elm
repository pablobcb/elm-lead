module Main.View exposing (..)

import Main.Model as Model exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html exposing (..)
import Container.OnScreenKeyboard.View as KbdView exposing (..)
import Container.OnScreenKeyboard.Update as KbdUpdate exposing (..)
import Container.Panel.View as PanelView exposing (..)
import Main.Update as Update exposing (..)


view : Model -> Html Update.Msg
view model =
    div [ class "dashboard" ]
        [ PanelView.panel PanelMsg
            model.panel
          --, div [ class "panel__brand" ]
          --[ span [] [ text "web lead" ]
          --, span [] [ text "2X" ]
          --, span [] [ text "virtual analog" ]
          --]
        , KbdView.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        , informationBar model
        ]


incrementer : String -> String -> a -> a -> Html a
incrementer label value up down =
    div [ class "incrementer" ]
        [ div [ class "incrementer__label" ] [ text label ]
        , button
            [ class "incrementer__btn"
            , onClick down
            ]
            []
        , span [ class "incrementer__label" ] [ text "-" ]
        , div [ class "incrementer__display" ] [ text ("." ++value) ]
        , span [ class "incrementer__label" ]
            [ text "+" ]
        , button
            [ class "incrementer__btn"
            , onClick up
            ]
            []
        ]


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
