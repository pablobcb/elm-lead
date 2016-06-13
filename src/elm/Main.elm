module Main exposing (..)

-- where

import Html exposing (Html, button, div, text, li, ul)
import Html.App
import Html.Attributes exposing (..)
import Ports exposing (..)
import Keyboard exposing (..)
import Mouse exposing (..)
import Container.OnScreenKeyboard as OnScreenKeyboard exposing (..)
import Container.Panel.Model as PanelModel exposing (..)
import Container.Panel.Update as PanelUpdate exposing (..)
import Container.Panel.View as PanelView exposing (..)


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { onScreenKeyboard : OnScreenKeyboard.Model
    , panel : PanelModel.Model
    }


init : ( Model, Cmd msg )
init =
    ( initModel, Cmd.none )


initModel : Model
initModel =
    { onScreenKeyboard = OnScreenKeyboard.init
    , panel = PanelModel.init
    }


updateOnScreenKeyboard : OnScreenKeyboard.Model -> Model -> Model
updateOnScreenKeyboard keyboard model =
    { model | onScreenKeyboard = keyboard }


updatePanel : PanelModel.Model -> Model -> Model
updatePanel panel model =
    { model | panel = panel }


type Msg
    = PanelMsg PanelUpdate.Msg
    | OnScreenKeyboardMsg OnScreenKeyboard.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PanelMsg subMsg ->
            let
                ( updatedPanel, _ ) =
                    PanelUpdate.update subMsg model.panel
            in
                ( updatePanel updatedPanel model
                , Cmd.map PanelMsg Cmd.none
                )

        OnScreenKeyboardMsg subMsg ->
            let
                ( updatedKbd, _ ) =
                    OnScreenKeyboard.update subMsg model.onScreenKeyboard
            in
                ( updateOnScreenKeyboard updatedKbd model
                , Cmd.map OnScreenKeyboardMsg Cmd.none
                )


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ PanelView.panel PanelMsg
            model.panel
        , OnScreenKeyboard.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs <| handleKeyDown OnScreenKeyboardMsg model.onScreenKeyboard
        , Keyboard.ups <| handleKeyUp OnScreenKeyboardMsg
        , Mouse.downs <| always <| OnScreenKeyboardMsg MouseClickDown
        , Mouse.ups <| always <| OnScreenKeyboardMsg MouseClickUp
        , midiInPort (\m -> OnScreenKeyboardMsg <| MidiMessageIn m)
        ]
