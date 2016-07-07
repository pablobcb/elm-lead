module Main.Update exposing (Msg(..), update)

import Container.Panel.Update as PanelUpdate
import Container.OnScreenKeyboard.Update as KbdUpdate
import Container.Panel.Update as PanelUpdate
import Component.Knob as Knob
import Main.Model as Model
import Process
import Task
import Port
import Preset


type Msg
    = PanelMsg PanelUpdate.Msg
    | OnScreenKeyboardMsg KbdUpdate.Msg
    | MouseUp
    | OnMidiStateChange Bool
    | NextPreset
    | PreviousPreset
    | PresetChange Preset.Preset


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        NextPreset ->
            ( model, {} |> Port.nextPreset )

        PreviousPreset ->
            ( model, {} |> Port.previousPreset )

        PresetChange preset ->
            let
                initModel =
                    Model.init preset model.midiSupport

                model' =
                    { initModel
                        | midiConnected = model.midiConnected
                        , onScreenKeyboard = model.onScreenKeyboard
                    }
            in
                ( model', Cmd.none )

        MouseUp ->
            let
                ( updatedPanel, panelCmd ) =
                    PanelUpdate.update (PanelUpdate.KnobMsg Knob.MouseUp)
                        model.panel

                model' =
                    Model.updatePanel updatedPanel model

                ( updatedKbd, kbdCmd ) =
                    KbdUpdate.update KbdUpdate.MouseUp model'.onScreenKeyboard

                model'' =
                    Model.updateOnScreenKeyboard updatedKbd model'
            in
                ( model''
                , Cmd.map (always MouseUp)
                    <| Cmd.batch [ panelCmd, kbdCmd ]
                )

        PanelMsg subMsg ->
            let
                ( updatedPanel, panelCmd ) =
                    PanelUpdate.update subMsg model.panel
            in
                ( Model.updatePanel updatedPanel model
                , Cmd.map PanelMsg panelCmd
                )

        OnScreenKeyboardMsg subMsg ->
            let
                ( updatedKbd, kbdCmd ) =
                    KbdUpdate.update subMsg model.onScreenKeyboard

                ( midiMsgInLedOn, blinkOffCmd ) =
                    case subMsg of
                        KbdUpdate.MidiMessageIn _ ->
                            ( True
                            , Process.sleep (50)
                                |> Task.perform (always KbdUpdate.NoOp)
                                    (always KbdUpdate.NoOp)
                            )

                        _ ->
                            ( False, Cmd.none )
            in
                ( Model.updateOnScreenKeyboard updatedKbd
                    { model | midiMsgInLedOn = midiMsgInLedOn }
                , Cmd.map OnScreenKeyboardMsg
                    <| Cmd.batch [ blinkOffCmd, kbdCmd ]
                )

        OnMidiStateChange state ->
            ( { model | midiConnected = state }, Cmd.none )
