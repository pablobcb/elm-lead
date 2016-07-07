module Container.OnScreenKeyboard.Update exposing (..)

--where

import Container.OnScreenKeyboard.Model as KbdModel
import Midi
import Char
import Maybe.Extra


type Msg
    = OctaveUp
    | OctaveDown
    | VelocityUp
    | VelocityDown
    | MouseEnter Midi.MidiValue
    | MouseLeave Midi.MidiValue
    | KeyOn Char
    | KeyOff Char
    | MouseUp
    | MouseDown
    | MidiMessageIn Midi.MidiMessage
    | NoOp
    | Panic


update : Msg -> KbdModel.Model -> ( KbdModel.Model, Cmd a )
update msg model =
    case msg of
        Panic ->
            ( KbdModel.panic model, Cmd.none )

        MidiMessageIn midiMsg ->
            -- TODO MOVE CODE TO SPECIFIC MODULE
            case midiMsg of
                (Just 144) :: (Just midiNote) :: _ ->
                    ( KbdModel.addPressedMidiNote model midiNote, Cmd.none )

                (Just 128) :: (Just midiNote) :: _ ->
                    ( KbdModel.removePressedMidiNote model midiNote, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        MouseDown ->
            let
                model' =
                    KbdModel.mouseDown model

                isKeyPressed midiNoteNumber =
                    Maybe.Extra.isJust
                        <| KbdModel.findPressedNote model' midiNoteNumber

                hoveringAndClickingKey =
                    model'.mousePressedNote
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', KbdModel.noteOnCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        MouseUp ->
            let
                isKeyPressed midiNoteNumber =
                    Maybe.Extra.isJust
                        <| KbdModel.findPressedNote model midiNoteNumber

                hoveringAndClickingKey =
                    model.mousePressedNote

                model' =
                    KbdModel.mouseUp model
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', KbdModel.noteOffCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        MouseEnter midiNoteNumber ->
            let
                model' =
                    KbdModel.mouseEnter model midiNoteNumber

                isKeyPressed midiNoteNumber =
                    Maybe.Extra.isJust
                        <| KbdModel.findPressedNote model' midiNoteNumber

                hoveringAndClickingKey =
                    model'.mousePressedNote
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', KbdModel.noteOnCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        MouseLeave midiNoteNumber ->
            let
                isKeyPressed midiNoteNumber =
                    Maybe.Extra.isJust
                        <| KbdModel.findPressedNote model midiNoteNumber

                hoveringAndClickingKey =
                    model.mousePressedNote

                model' =
                    KbdModel.mouseLeave model
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber ->
                        if isKeyPressed midiNoteNumber then
                            ( model', Cmd.none )
                        else
                            ( model', KbdModel.noteOffCommand (.velocity model') midiNoteNumber )

                    Nothing ->
                        ( model', Cmd.none )

        OctaveDown ->
            ( KbdModel.octaveDown model, Cmd.none )

        OctaveUp ->
            ( KbdModel.octaveUp model, Cmd.none )

        VelocityDown ->
            ( KbdModel.velocityDown model, Cmd.none )

        VelocityUp ->
            ( KbdModel.velocityUp model, Cmd.none )

        KeyOn symbol ->
            let
                model' =
                    KbdModel.addPressedNote model symbol

                midiNoteNumber =
                    KbdModel.keyToMidiNoteNumber ( symbol, model.octave )

                hoveringAndClickingKey =
                    model.mousePressedNote
            in
                case hoveringAndClickingKey of
                    Just midiNoteNumber' ->
                        if midiNoteNumber == midiNoteNumber' then
                            ( model', Cmd.none )
                        else
                            ( model', KbdModel.noteOnCommand (.velocity model) midiNoteNumber )

                    Nothing ->
                        ( model', KbdModel.noteOnCommand (.velocity model) midiNoteNumber )

        KeyOff symbol ->
            let
                releasedKey =
                    KbdModel.findPressedKey model symbol

                hoveringAndClickingKey =
                    model.mousePressedNote

                model' =
                    KbdModel.removePressedNote model symbol
            in
                case releasedKey of
                    Just ( symbol', midiNoteNumber ) ->
                        case hoveringAndClickingKey of
                            Just midiNoteNumber' ->
                                if midiNoteNumber == midiNoteNumber' then
                                    ( model', Cmd.none )
                                else
                                    ( model'
                                    , KbdModel.noteOffCommand model.velocity
                                        midiNoteNumber
                                    )

                            Nothing ->
                                ( model'
                                , KbdModel.noteOffCommand model.velocity
                                    midiNoteNumber
                                )

                    Nothing ->
                        ( model', Cmd.none )


handleKeyDown : (Msg -> a) -> KbdModel.Model -> Char.KeyCode -> a
handleKeyDown msg model keyCode =
    let
        symbol =
            keyCode |> Char.fromCode |> Char.toLower

        allowedInput =
            List.member symbol KbdModel.allowedInputKeys

        isLastOctave =
            (.octave model) == 8

        unusedKeys =
            List.member symbol KbdModel.unusedKeysOnLastOctave

        symbolAlreadyPressed =
            Maybe.Extra.isJust <| KbdModel.findPressedKey model symbol
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
            not <| List.member symbol KbdModel.pianoKeys

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
