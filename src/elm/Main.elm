module Main exposing (..)

import Html.App
import Port
import Preset
import Keyboard exposing (..)
import Mouse exposing (..)
import Container.OnScreenKeyboard.Update as KbdUpdate exposing (..)
import Container.Panel.Update as PanelUpdate exposing (..)
import Component.Knob as Knob exposing (..)
import Main.Model as Model exposing (..)
import Main.Update as Update exposing (..)
import Main.View as View exposing (..)


main : Program Preset.Preset
main =
    Html.App.programWithFlags
        { init = \preset -> ( initModel preset, Cmd.none )
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }


subscriptions : Model.Model -> Sub Update.Msg
subscriptions model =
    Sub.batch
        [ Port.midiIn <| OnScreenKeyboardMsg << MidiMessageIn
        , Port.midiStateChange OnMidiStateChange
        , Port.presetChange <| PanelMsg << PanelUpdate.PresetChange
        , Port.panic <| always <| OnScreenKeyboardMsg Panic
        , Keyboard.ups <| handleKeyUp OnScreenKeyboardMsg
        , Keyboard.downs
            <| handleKeyDown OnScreenKeyboardMsg model.onScreenKeyboard
        , Mouse.ups <| always Update.MouseUp
        , Mouse.moves
            <| \{ y } ->
                y |> Knob.MouseMove |> PanelUpdate.KnobMsg |> PanelMsg
        ]
