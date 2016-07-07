module Main exposing (main, subscriptions)

import Html.App
import Port
import Keyboard
import Mouse
import Container.OnScreenKeyboard.Update as KbdUpdate
import Container.Panel.Update as PanelUpdate
import Component.Knob as Knob
import Main.Model as Model
import Main.Update as Update
import Main.View as View


main : Program Model.InitialFlags
main =
    Html.App.programWithFlags
        { init =
            \flags ->
                ( Model.init flags.preset flags.midiSupport, Cmd.none )
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }


subscriptions : Model.Model -> Sub Update.Msg
subscriptions model =
    Sub.batch
        [ Port.midiIn <| Update.OnScreenKeyboardMsg << KbdUpdate.MidiMessageIn
        , Port.midiStateChange Update.OnMidiStateChange
        , Port.presetChange <| Update.PresetChange
        , Port.panic <| always <| Update.OnScreenKeyboardMsg KbdUpdate.Panic
        , Keyboard.ups <| KbdUpdate.handleKeyUp Update.OnScreenKeyboardMsg
        , Keyboard.downs
            <| KbdUpdate.handleKeyDown Update.OnScreenKeyboardMsg
                model.onScreenKeyboard
        , Mouse.ups <| always Update.MouseUp
        , Mouse.moves
            <| \{ y } ->
                y |> Knob.MouseMove |> PanelUpdate.KnobMsg |> Update.PanelMsg
        ]
