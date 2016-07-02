module Main.Update exposing (..)

import Container.Panel.Update as PanelUpdate exposing (..)
import Container.OnScreenKeyboard.Update as KbdUpdate exposing (..)
import Container.Panel.Update as PanelUpdate exposing (..)
import Component.Knob as Knob exposing (..)
import Main.Model as Model exposing (..)


type Msg
    = PanelMsg PanelUpdate.Msg
    | OnScreenKeyboardMsg KbdUpdate.Msg
    | MouseUp
    | OnMidiStateChange Bool
    --| NoOp


update : Msg -> Model.Model -> ( Model.Model, Cmd Msg )
update msg model =
    case msg of
        --NoOp ->
        --    Debug.log "NoOp" <|
        --    ( model, Cmd.none )
--
        MouseUp ->
            let
                ( updatedPanel, panelCmd ) =
                    PanelUpdate.update (PanelUpdate.KnobMsg Knob.MouseUp)
                        model.panel

                model' =
                    updatePanel updatedPanel model

                ( updatedKbd, kbdCmd ) =
                    KbdUpdate.update KbdUpdate.MouseUp model'.onScreenKeyboard

                model'' =
                    updateOnScreenKeyboard updatedKbd model'
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
                ( updatePanel updatedPanel model
                , Cmd.map PanelMsg panelCmd
                )

        OnScreenKeyboardMsg subMsg ->
            let
                ( updatedKbd, kbdCmd ) =
                    KbdUpdate.update subMsg model.onScreenKeyboard
            in
                ( updateOnScreenKeyboard updatedKbd model
                , Cmd.map OnScreenKeyboardMsg kbdCmd
                )

        OnMidiStateChange state ->
            ( { model
                | midiConnected = state
                , searchingMidi = False
              }
            , Cmd.none
            )
