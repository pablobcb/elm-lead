module Main exposing (..)

-- where

import Html exposing (..)
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
    , midiConnected : Bool
    , searchingMidi : Bool
    }


initModel : Preset.Preset -> Model
initModel preset =
    { onScreenKeyboard = KbdModel.init
    , panel = PanelModel.init preset
    , midiConnected = False
    , searchingMidi = True
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
    | OnMidiStateChange Bool



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

        OnMidiStateChange state ->
            ( { model | midiConnected = state }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ PanelView.panel PanelMsg
            model.panel
        , KbdView.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        , informationBar model
        ]


informationBar : Model -> Html Msg
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
    in
        div [ class "information-bar" ]
            [ span [ class "information-bar__item" ]
                [ octaveText |> text ]
            , span [ class "information-bar__item" ] [ text velocityText ]
            , div [ class "midi-indicator" ]
                [ div [] [ text "MIDI" ]
                , div
                    [ class
                        <| "midi-indicator__status midi-indicator__status--"
                        ++ (if model.searchingMidi then
                                "searching"
                            else if model.midiConnected then
                                "active"
                            else
                                "inactive"
                           )
                    ]
                    []
                ]
            , a [ href "https://github.com/pablobcb/elm-lead" ]
                [ img [ src "gh.png", class "information-bar__gh-link" ] [] ]
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
