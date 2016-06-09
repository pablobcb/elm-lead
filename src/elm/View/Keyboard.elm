module View.Keyboard exposing (keyboard)

-- where

import String exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Update exposing (..)
import Msg exposing (..)
import Model.Model exposing (..)


octaveKeys : List String
octaveKeys =
    [ "c", "cs", "d", "ds", "e", "f", "fs", "g", "gs", "a", "as", "b" ]


midiNotes : List Int
midiNotes =
    [0..127]


onScreenKeyboardKeys : List String
onScreenKeyboardKeys =
    (List.concat <| List.repeat 10 octaveKeys) ++ (List.take 8 octaveKeys)


onMouseEnter' : Int -> Html.Attribute Msg
onMouseEnter' midiNote =
    midiNote |> MouseEnter |> Html.Events.onMouseEnter


onMouseLeave' : Int -> Html.Attribute Msg
onMouseLeave' midiNote =
    midiNote |> MouseLeave |> Html.Events.onMouseLeave


key : Model -> String -> Int -> Html Msg
key model noteName midiNote =
    li
        [ getKeyClass model noteName midiNote |> class
        , onMouseEnter' midiNote
        , onMouseLeave' midiNote
        ]
        []


keys : Model -> List (Html Msg)
keys model =
    List.map2 (key model) onScreenKeyboardKeys midiNotes


getKeyClass : Model -> String -> Int -> String
getKeyClass model noteName midiNote =
    let
        isSharpKey =
            String.contains "s" noteName

        middleC =
            if midiNote == 60 then
                "c3"
            else
                ""

        keyPressed =
            if List.member midiNote <| List.map snd model.pressedNotes then
                "pressed"
            else
                ""

        position =
            if isSharpKey then
                "higher"
            else
                "lower"
    in
        [ "key", position, keyPressed, middleC ]
            |> List.filter ((/=) "")
            |> String.join " "


keyboard : Model -> Html Msg
keyboard model =
    ul [ class "keyboard" ] <| keys model
