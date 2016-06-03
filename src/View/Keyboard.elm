module View.Keyboard exposing (keyboard) -- where

import String exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)

import Update exposing (..)
import Msg exposing (..)

import Model.VirtualKeyboard exposing (..)

octaveKeys : List String
octaveKeys =
  [ "c", "cs", "d", "ds", "e", "f", "fs", "g", "gs", "a", "as", "b" ]

midiNotes : List Int
midiNotes =
  [ 0 .. 127 ]

onScreenKeyboardKeys : List String  
onScreenKeyboardKeys =
  (List.concat <| List.repeat 10 octaveKeys) ++ (List.take 8 octaveKeys)

onMouseEnter' : Int -> Html.Attribute Msg
onMouseEnter' midiNote = 
  midiNote |> MouseEnter |> Html.Events.onMouseEnter

onMouseLeave' : Int -> Html.Attribute Msg
onMouseLeave' midiNote = 
  midiNote |> MouseLeave |> Html.Events.onMouseEnter

key : String -> Int -> Html Msg
key noteName midiNote = 
  li [ getKeyClass noteName midiNote |> class, onMouseEnter' midiNote ] []

keys : List (Html Msg)
keys =
  List.map2 key onScreenKeyboardKeys midiNotes

getKeyClass : String -> Int -> String
getKeyClass noteName midiNote =
  let keyPosition =
    if String.contains "s" noteName then
      "higher"
    else
      ((++) "lower") <|
        if midiNote == 60 then
          " c3"
        else
          ""
  in
    "key " ++ keyPosition ++ " " ++ noteName

keyboard : Html Msg
keyboard =
  ul [ class "keyboard" ] keys

