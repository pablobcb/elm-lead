module Container.OnScreenKeyboard.View exposing (..)

-- where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (map)
import Container.OnScreenKeyboard.Model as Model exposing (..)
import Container.OnScreenKeyboard.Update as Update exposing (..)
import String exposing (..)
import Midi exposing (..)


octaveKeys : List String
octaveKeys =
    [ "c", "cs", "d", "ds", "e", "f", "fs", "g", "gs", "a", "as", "b" ]


midiNotes : List Int
midiNotes =
    [0..127]


onScreenKeyboardKeys : List String
onScreenKeyboardKeys =
    (List.concat <| List.repeat 10 octaveKeys) ++ (List.take 8 octaveKeys)


onMouseEnter : MidiNote -> Html.Attribute Msg
onMouseEnter midiNote =
    midiNote |> MouseEnter |> Html.Events.onMouseEnter


onMouseLeave : MidiNote -> Html.Attribute Msg
onMouseLeave midiNote =
    midiNote |> MouseLeave |> Html.Events.onMouseLeave


key : Model -> String -> MidiNote -> Html Msg
key model noteName midiNote =
    li
        [ getKeyClass model noteName midiNote |> class
        , onMouseEnter midiNote
        , onMouseLeave midiNote
        ]
        []


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

        note =
            if (String.length noteName) > 1 then
                ""
            else
                noteName
    in
        [ "key", position, keyPressed, middleC, note ]
            |> List.filter ((/=) "")
            |> String.join " "


view : Model -> Html Msg
view model =
    let
        keys =
            List.map2 (key model) onScreenKeyboardKeys midiNotes
    in
        div []
            [ ul [ class "keyboard" ] <| keys
            , informationBar model
            ]


informationBar : Model -> Html Msg
informationBar model =
    let
        startOctave =
            model |> .octave |> toString

        endOctave =
            model |> .octave |> (+) 1 |> toString

        octaveText =
            "Octave is C" ++ startOctave ++ " to C" ++ endOctave

        velocityText =
            ("Velocity is " ++ (model |> .velocity |> toString))
    in
        div [ class "information-bar" ]
            [ span [ class "information-bar__item" ] [ octaveText |> text ]
            , span [ class "information-bar__item" ] [ velocityText |> text ]
            ]


keyboard : (Msg -> a) -> Model -> Html a
keyboard keyboardMsg model =
    Html.App.map keyboardMsg
        <| view model