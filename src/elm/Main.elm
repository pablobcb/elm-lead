module Main exposing (..)

-- where

import Html exposing (Html, button, div, text, li, ul)
import Html.App
import Html.Attributes exposing (..)
import Port
import Preset
import Keyboard exposing (..)
import Mouse exposing (..)
import Container.OnScreenKeyboard.Model as KbdModel exposing (..)
import Container.OnScreenKeyboard.Update as KbdUpdate exposing (..)
import Container.OnScreenKeyboard.View as KbdView exposing (..)
import Container.Panel.Model as PanelModel exposing (..)
import Container.Panel.Update as PanelUpdate exposing (..)
import Container.Panel.View as PanelView exposing (..)
import Component.Knob as Knob exposing (..)


main : Program Preset.Preset
main =
    Html.App.programWithFlags
        { init = \preset -> ( initModel preset, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { onScreenKeyboard : KbdModel.Model
    , panel : PanelModel.Model
    }


initModel : Preset.Preset -> Model
initModel preset =
    { onScreenKeyboard = KbdModel.init
    , panel = PanelModel.init preset
    }


updateOnScreenKeyboard : KbdModel.Model -> Model -> Model
updateOnScreenKeyboard keyboard model =
    { model | onScreenKeyboard = keyboard }


updatePanel : PanelModel.Model -> Model -> Model
updatePanel panel model =
    { model | panel = panel }


type Msg
    = PanelMsg PanelUpdate.Msg
    | OnScreenKeyboardMsg KbdUpdate.Msg
    | MouseUp



--update map


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ PanelView.panel PanelMsg
            model.panel
        , KbdView.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Port.midiIn
            (\midiMsg ->
                MidiMessageIn midiMsg |> OnScreenKeyboardMsg
            )
        , Port.presetChange
            (\preset ->
                PanelUpdate.PresetChange preset |> PanelMsg
            )
        , Port.panic
            <| always
            <| OnScreenKeyboardMsg Panic
        , Keyboard.downs
            <| handleKeyDown OnScreenKeyboardMsg
                model.onScreenKeyboard
        , Keyboard.ups
            <| handleKeyUp OnScreenKeyboardMsg
        , Mouse.ups
            <| always MouseUp
        , Mouse.moves
            (\{ y } ->
                y |> Knob.MouseMove |> PanelUpdate.KnobMsg |> PanelMsg
            )
        ]
