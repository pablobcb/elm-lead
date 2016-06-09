import Html exposing (Html, button, div, text, li, ul)
import Html.Attributes exposing (class)
import Html.App as Html
import Html.Events exposing (onClick)
import Ports exposing (..)
import Keyboard exposing (..)
import Mouse exposing (..)
import Char exposing (..)
import Maybe.Extra exposing (..)

import Msg exposing (..)
import Update exposing (..)
import View.Dashboard exposing (..)
import Model.Note exposing (..)
import Model.Midi exposing (..)
import Model.Model as Model exposing (..)

import Debug exposing (..)

main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


init : (Model, Cmd msg)
init =
  (initModel, Cmd.none)

view : Model -> Html Msg
view model =
  dashboard model


handleKeyDown : Model -> Keyboard.KeyCode -> Msg
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
    if (not allowedInput) || (isLastOctave && unusedKeys)  || symbolAlreadyPressed then
      NoOp
    else
      case symbol of
        'z' ->
          OctaveDown

        'x' ->
          OctaveUp

        'c' ->
          VelocityDown

        'v' ->
          VelocityUp

        symbol ->
          KeyOn symbol


handleKeyUp : Model -> Keyboard.KeyCode -> Msg
handleKeyUp model keyCode =
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
      NoOp
    else
      KeyOff symbol

-- Subscriptions
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Keyboard.downs (handleKeyDown model)
    , Keyboard.ups (handleKeyUp model)
    , Mouse.downs <| always MouseClickDown
    , Mouse.ups <| always MouseClickUp
    ]
    
