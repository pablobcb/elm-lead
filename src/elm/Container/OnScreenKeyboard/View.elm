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
    [ "c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b" ]


onScreenKeyboardKeys : List String
onScreenKeyboardKeys =
    (List.concat <| List.repeat 10 octaveKeys) ++ (List.take 8 octaveKeys)


onMouseEnter : MidiNote -> Html.Attribute Msg
onMouseEnter midiNote =
    midiNote |> MouseEnter |> Html.Events.onMouseEnter


onMouseLeave : MidiNote -> Html.Attribute Msg
onMouseLeave midiNote =
    midiNote |> MouseLeave |> Html.Events.onMouseLeave


key : Model -> String -> MidiNote -> Int -> Html Msg
key model noteName midiNote octave =
    let
        isCurrentOctave =
            (model.octave == octave)
                || ((model.octave == octave - 1)
                        && List.member noteName
                            ["c", "c#","d","d#"]
                   )

        classes =
            getKeyClass model noteName midiNote isCurrentOctave
    in
        li
            [ classes |> class
            , onMouseEnter midiNote
            , onMouseLeave midiNote
            ]
            []


getKeyClass : Model -> String -> Int -> Bool -> String
getKeyClass model noteName midiNote highlight =
    let
        isSharpKey =
            String.contains "#" noteName

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

        currentOctave =
            if highlight then
                "current-octave"
            else
                ""
    in
        [ "key", position, keyPressed, note, currentOctave, middleC ]
            |> List.filter ((/=) "")
            |> String.join " "


view : Model -> Html Msg
view model =
    let
        keys =
            List.map3 (key model)
                onScreenKeyboardKeys
                [0..127]
                Midi.midiNoteOctaves
    in
        div []
            [ ul [ class "keyboard" ] <| keys
            , informationBar model
            ]


keyboard : (Msg -> a) -> Model -> Html a
keyboard keyboardMsg model =
    Html.App.map keyboardMsg
        <| view model


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
