module Container.OnScreenKeyboard.Update exposing (..)

--where

import Container.OnScreenKeyboard.Model as KbdModel exposing (..)
import Midi exposing (..)
import Char exposing (..)
import Maybe.Extra exposing (..)


type Msg
    = OctaveUp
    | OctaveDown
    | VelocityUp
    | VelocityDown
    | MouseEnter MidiNote
    | MouseLeave MidiNote
    | KeyOn Char
    | KeyOff Char
    | MouseClickUp
    | MouseClickDown
    | MidiMessageIn MidiMessage
    | NoOp
    | Panic


update : Msg -> KbdModel.Model -> ( KbdModel.Model, Cmd a )
update msg model =
    case msg of
        Panic ->
            ( panic model, Cmd.none )

        MidiMessageIn midiMsg ->
            Debug.log "MIDI MSG" ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        MouseClickDown ->
            let
                model' =
                    mouseDown model

                isKeyPressed midiNoteNumber =
                    isJust <| findPressedNote model' midiNoteNumber

                hoveringAndClickingKey =
                    model'.mousePressedNote
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', noteOnCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        MouseClickUp ->
            let
                isKeyPressed midiNoteNumber =
                    isJust <| findPressedNote model midiNoteNumber

                hoveringAndClickingKey =
                    model.mousePressedNote

                model' =
                    mouseUp model
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', noteOffCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        MouseEnter midiNoteNumber ->
            let
                model' =
                    mouseEnter model midiNoteNumber

                isKeyPressed midiNoteNumber =
                    isJust <| findPressedNote model' midiNoteNumber

                hoveringAndClickingKey =
                    model'.mousePressedNote
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', noteOnCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        MouseLeave midiNoteNumber ->
            let
                isKeyPressed midiNoteNumber =
                    isJust <| findPressedNote model midiNoteNumber

                hoveringAndClickingKey =
                    model.mousePressedNote

                model' =
                    mouseLeave model
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', noteOffCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        OctaveDown ->
            ( octaveDown model, Cmd.none )

        OctaveUp ->
            ( octaveUp model, Cmd.none )

        VelocityDown ->
            ( velocityDown model, Cmd.none )

        VelocityUp ->
            ( velocityUp model, Cmd.none )

        KeyOn symbol ->
            let
                model' =
                    addPressedNote model symbol

                midiNoteNumber =
                    keyToMidiNoteNumber ( symbol, model.octave )

                hoveringAndClickingKey =
                    model.mousePressedNote
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber' ->
                        if midiNoteNumber == midiNoteNumber' then
                            ( model', Cmd.none )
                        else
                            ( model', noteOnCommand (.velocity model) midiNoteNumber )

                    Nothing ->
                        ( model', noteOnCommand (.velocity model) midiNoteNumber )

        KeyOff symbol ->
            let
                releasedKey =
                    findPressedKey model symbol

                hoveringAndClickingKey =
                    model.mousePressedNote

                model' =
                    removePressedNote model symbol
            in
                case releasedKey of
                    Just ( symbol', midiNoteNumber ) ->
                        case hoveringAndClickingKey of
                            Just midiNoteNumber' ->
                                if midiNoteNumber == midiNoteNumber' then
                                    ( model', Cmd.none )
                                else
                                    ( model', noteOffCommand model.velocity midiNoteNumber )

                            Nothing ->
                                ( model', noteOffCommand model.velocity midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )


handleKeyDown : (Msg -> a) -> KbdModel.Model -> Char.KeyCode -> a
handleKeyDown msg model keyCode =
    let
        symbol =
            keyCode |> Char.fromCode |> Char.toLower

        allowedInput =
            List.member symbol allowedInputKeys

        isLastOctave =
            (.octave model) == 8

        unusedKeys =
            List.member symbol unusedKeysOnLastOctave

        symbolAlreadyPressed =
            isJust <| findPressedKey model symbol
    in
        if
            (not allowedInput)
                || (isLastOctave && unusedKeys)
                || symbolAlreadyPressed
        then
            msg NoOp
        else
            case symbol of
                'z' ->
                    msg OctaveDown

                'x' ->
                    msg OctaveUp

                'c' ->
                    msg VelocityDown

                'v' ->
                    msg VelocityUp

                symbol ->
                    msg <| KeyOn symbol


handleKeyUp : (Msg -> a) -> Char.KeyCode -> a
handleKeyUp msg keyCode =
    let
        symbol =
            keyCode |> Char.fromCode |> Char.toLower

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
            msg NoOp
        else
            msg <| KeyOff symbol
