module Components.OnScreenKeyboard exposing (..)

-- where

import Char exposing (..)
import Keyboard exposing (..)
import List exposing (..)
import Maybe.Extra exposing (..)
import Model.Note as Note exposing (..)
import Model.Midi as Midi exposing (..)
import Ports exposing (..)


type alias PressedKey =
    ( Char, MidiNote )


type alias Model =
    { octave : Octave
    , velocity : Velocity
    , pressedNotes : List PressedKey
    , clickedAndHovering : Bool
    , mouseHoverNote : Maybe MidiNote
    , mousePressedNote : Maybe MidiNote
    , midiControllerPressedNotes : List MidiNote
    }


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


initOnScreenKeyboard : Model
initOnScreenKeyboard =
    { octave = 3
    , velocity = 100
    , pressedNotes = []
    , clickedAndHovering = False
    , mouseHoverNote = Nothing
    , mousePressedNote = Nothing
    , midiControllerPressedNotes = []
    }


pianoKeys : List Char
pianoKeys =
    [ 'a'
    , 'w'
    , 's'
    , 'e'
    , 'd'
    , 'f'
    , 't'
    , 'g'
    , 'y'
    , 'h'
    , 'u'
    , 'j'
    , 'k'
    , 'o'
    , 'l'
    , 'p'
    ]


allowedInputKeys : List Char
allowedInputKeys =
    [ 'z', 'c', 'x', 'v' ] ++ pianoKeys


unusedKeysOnLastOctave : List Char
unusedKeysOnLastOctave =
    [ 'h', 'u', 'j', 'k', 'o', 'l', 'p' ]


keyToMidiNoteNumber : ( Char, Octave ) -> MidiNote
keyToMidiNoteNumber ( symbol, octave ) =
    Midi.noteToMidiNumber
        <| case symbol of
            'a' ->
                ( C, octave )

            'w' ->
                ( Db, octave )

            's' ->
                ( D, octave )

            'e' ->
                ( Eb, octave )

            'd' ->
                ( E, octave )

            'f' ->
                ( F, octave )

            't' ->
                ( Gb, octave )

            'g' ->
                ( G, octave )

            'y' ->
                ( Ab, octave )

            'h' ->
                ( A, octave )

            'u' ->
                ( Bb, octave )

            'j' ->
                ( B, octave )

            'k' ->
                ( C, octave + 1 )

            'o' ->
                ( Db, octave + 1 )

            'l' ->
                ( D, octave + 1 )

            'p' ->
                ( Eb, octave + 1 )

            _ ->
                Debug.crash ("Note and octave outside MIDI bounds: " ++ toString symbol ++ " " ++ toString octave)


velocityDown : Model -> Model
velocityDown model =
    let
        vel =
            .velocity model
    in
        { model
            | velocity =
                if vel < 40 then
                    1
                else if vel == 127 then
                    120
                else
                    vel - 20
        }


velocityUp : Model -> Model
velocityUp model =
    let
        vel =
            .velocity model
    in
        { model
            | velocity =
                if vel == 1 then
                    20
                else if vel >= 120 then
                    127
                else
                    vel + 20
        }


octaveDown : Model -> Model
octaveDown model =
    { model | octave = max (-2) ((.octave model) - 1) }


octaveUp : Model -> Model
octaveUp model =
    { model | octave = min 8 (model |> .octave |> (+) 1) }


mouseDown : Model -> Model
mouseDown model =
    { model | clickedAndHovering = True, mousePressedNote = model.mouseHoverNote }


mouseUp : Model -> Model
mouseUp model =
    { model | clickedAndHovering = False, mousePressedNote = Nothing }


mouseEnter : Model -> Int -> Model
mouseEnter model key =
    { model
        | mouseHoverNote = Just key
        , mousePressedNote =
            if model.clickedAndHovering then
                Just key
            else
                Nothing
    }


mouseLeave : Model -> Int -> Model
mouseLeave model key =
    { model | mouseHoverNote = Nothing, mousePressedNote = Nothing }


addClickedNote : Model -> MidiNote -> Model
addClickedNote model midiNote =
    { model | mousePressedNote = Just midiNote }


removeClickedNote : Model -> MidiNote -> Model
removeClickedNote model midiNote =
    { model | mousePressedNote = Just midiNote }


addPressedNote : Model -> Char -> Model
addPressedNote model symbol =
    { model | pressedNotes = (.pressedNotes model) ++ [ ( symbol, keyToMidiNoteNumber ( symbol, .octave model ) ) ] }


removePressedNote : Model -> Char -> Model
removePressedNote model symbol =
    { model | pressedNotes = List.filter (\( symbol', _ ) -> symbol /= symbol') model.pressedNotes }


findPressedKey : Model -> Char -> Maybe PressedKey
findPressedKey model symbol =
    List.head <| List.filter (\( symbol', _ ) -> symbol == symbol') model.pressedNotes


findPressedNote : Model -> MidiNote -> Maybe PressedKey
findPressedNote model midiNote =
    List.head <| List.filter (\( _, midiNote' ) -> midiNote == midiNote') model.pressedNotes


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
                    mouseLeave model midiNoteNumber
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


noteOnCommand : Velocity -> Int -> Cmd msg
noteOnCommand velocity midiNoteNumber =
    noteOnMessage midiNoteNumber velocity |> midiOutPort


noteOffCommand : Velocity -> Int -> Cmd msg
noteOffCommand velocity midiNoteNumber =
    noteOffMessage midiNoteNumber velocity |> midiOutPort
