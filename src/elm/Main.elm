module Main exposing (..)

-- where

import Html exposing (Html, button, div, text, li, ul)
import Html.App
import Html.Attributes exposing (..)
import Ports exposing (..)
import Keyboard exposing (..)
import Mouse exposing (..)
import Container.OnScreenKeyboard as OnScreenKeyboard exposing (..)
import Container.Panel as Panel


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd msg )
init =
    ( initModel, Cmd.none )



-- Model


type alias Model =
    --OSC
    { onScreenKeyboard : OnScreenKeyboard.Model
    , panel : Panel.Model
    }


initModel : Model
initModel =
    { onScreenKeyboard = OnScreenKeyboard.init
    , panel = Panel.init
    }


updateOnScreenKeyboard : OnScreenKeyboard.Model -> Model -> Model
updateOnScreenKeyboard keyboard model =
    { model | onScreenKeyboard = keyboard }


updatePanel : Panel.Model -> Model -> Model
updatePanel panel model =
    { model | panel = panel }



-- Update


type Msg
    = PanelMsg Panel.Msg
    | OnScreenKeyboardMsg OnScreenKeyboard.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PanelMsg subMsg ->
            let
                ( updatedPanel, _ ) =
                    Panel.update subMsg model.panel
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
        [ Panel.panel PanelMsg
            model.panel
        , OnScreenKeyboard.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs <| handleKeyDown OnScreenKeyboardMsg model.onScreenKeyboard
        , Keyboard.ups <| handleKeyUp OnScreenKeyboardMsg
        , Mouse.downs <| always <| OnScreenKeyboardMsg MouseClickDown
        , Mouse.ups <| always <| OnScreenKeyboardMsg MouseClickUp
        , midiInPort (\m -> OnScreenKeyboardMsg <| MidiMessageIn m)
        ]
