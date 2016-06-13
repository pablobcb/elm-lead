module Main exposing (..)

-- where

import Html exposing (Html, button, div, text, li, ul)
import Html.App
import Html.Attributes exposing (..)
import Ports exposing (..)
import Keyboard exposing (..)
import Mouse exposing (..)
import Char exposing (..)
import Maybe.Extra exposing (..)
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



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs (handleKeyDown model.onScreenKeyboard)
        , Keyboard.ups handleKeyUp
        , Mouse.downs <| always <| OnScreenKeyboardMsg MouseClickDown
        , Mouse.ups <| always <| OnScreenKeyboardMsg MouseClickUp
        , midiInPort (\m -> OnScreenKeyboardMsg <| MidiMessageIn m)
        ]



-- Update


type Msg
    = PanelMsg Panel.Msg
    | OnScreenKeyboardMsg OnScreenKeyboard.Msg


updateMap model childUpdate childMsg getChild reduxor msg =
    let
        ( updatedChildModel, childCmd ) =
            childUpdate childMsg (getChild model)
    in
        ( reduxor updatedChildModel model
        , Cmd.map msg Cmd.none
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PanelMsg subMsg ->
            updateMap model
                Panel.update
                subMsg
                .panel
                updatePanel
                PanelMsg

        OnScreenKeyboardMsg subMsg ->
            updateMap model
                OnScreenKeyboard.update
                subMsg
                .onScreenKeyboard
                updateOnScreenKeyboard
                OnScreenKeyboardMsg


view : Model -> Html Msg
view model =
    div [ class "dashboard" ]
        [ Panel.panel PanelMsg
            model.panel
        , OnScreenKeyboard.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        ]



--TODO move to keyboard


--handleKeyDown : OnScreenKeyboard.Model -> Keyboard.KeyCode -> Msg
handleKeyDown model keyCode =
    let
        symbol =
            keyCode |> Char.fromCode |> toLower

        allowedInput =
            List.member symbol allowedInputKeys

        isLastOctave =
            (.octave model) == 8

        unusedKeys =
            List.member symbol unusedKeysOnLastOctave

        symbolAlreadyPressed =
            isJust <| findPressedKey model symbol
    in
        if (not allowedInput) || (isLastOctave && unusedKeys) || symbolAlreadyPressed then
            OnScreenKeyboardMsg NoOp
        else
            case symbol of
                'z' ->
                    OnScreenKeyboardMsg OctaveDown

                'x' ->
                    OnScreenKeyboardMsg OctaveUp

                'c' ->
                    OnScreenKeyboardMsg VelocityDown

                'v' ->
                    OnScreenKeyboardMsg VelocityUp

                symbol ->
                    OnScreenKeyboardMsg <| KeyOn symbol


==handleKeyUp : Keyboard.KeyCode -> Msg
handleKeyUp keyCode =
    let
        symbol =
            keyCode |> Char.fromCode |> toLower

        invalidKey =
            not <| List.member symbol pianoKeys

        --isMousePressingSameKey =
        --  case findPressedKey model symbol of
        --    Just (symbol', midiNote') ->
        --      case model.mousePressedKey of
        --        Just midiNote ->
        --          (==) midiNote' midiNote
        --        Nothing ->
        --          False
        --    Nothing->
        --      False
    in
        if invalidKey then
            OnScreenKeyboardMsg NoOp
        else
            OnScreenKeyboardMsg <| KeyOff symbol
