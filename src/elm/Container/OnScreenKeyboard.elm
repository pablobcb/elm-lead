module Container.OnScreenKeyboard exposing (..)

-- where

import List exposing (..)
import Maybe.Extra exposing (..)
import Note exposing (..)
import Midi exposing (..)
import Port exposing (..)
import String exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.App exposing (map)
import Char exposing (..)


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


init : Model
init =
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



--TODO: RENAME ME


mouseLeave : Model -> Model
mouseLeave model =
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


updateMap model childUpdate childMsg getChild reduxor msg =
    let
        ( updatedChildModel, childCmd ) =
            childUpdate childMsg (getChild model)
    in
        ( reduxor updatedChildModel model
        , Cmd.map msg childCmd
        )


update : Msg -> Model -> ( Model, Cmd a )
update msg model =
    let
        updateMap' =
            updateMap model
    in
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


noteOnCommand : Velocity -> MidiNote -> Cmd msg
noteOnCommand velocity midiNoteNumber =
    noteOnMessage midiNoteNumber velocity |> midiOutPort


noteOffCommand : Velocity -> MidiNote -> Cmd msg
noteOffCommand velocity midiNoteNumber =
    noteOffMessage midiNoteNumber velocity |> midiOutPort



--VIEW


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


handleKeyDown : (Msg -> a) -> Model -> Char.KeyCode -> a
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
