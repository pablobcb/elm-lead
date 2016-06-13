module Main exposing (..)

-- where

import Html exposing (Html, button, div, text, li, ul)
import Html.App as Html
import Ports exposing (..)
import Keyboard exposing (..)
import Mouse exposing (..)
import Char exposing (..)
import Maybe.Extra exposing (..)
import Msg exposing (..)
import Update exposing (..)
import View.Dashboard exposing (..)
import Model.Model as Model exposing (..)
import Components.OnScreenKeyboard as OnScreenKeyboard exposing (..)


main : Program Never
main =
    Html.program
        { init = init
        , view = view
        , update = Update.update
        , subscriptions = subscriptions
        }


init : ( Model.Model, Cmd msg )
init =
    ( initModel, Cmd.none )


view : Model.Model -> Html Msg.Msg
view model =
    dashboard model


handleKeyDown : OnScreenKeyboard.Model -> Keyboard.KeyCode -> Msg.Msg
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


handleKeyUp : Keyboard.KeyCode -> Msg.Msg
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



-- Subscriptions


subscriptions : Model.Model -> Sub Msg.Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs (handleKeyDown model.onScreenKeyboard)
        , Keyboard.ups handleKeyUp
        , Mouse.downs <| always <| OnScreenKeyboardMsg MouseClickDown
        , Mouse.ups <| always <| OnScreenKeyboardMsg MouseClickUp
        , midiInPort (\m -> OnScreenKeyboardMsg <| MidiMessageIn m)
        ]
