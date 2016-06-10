module Update exposing (..)

-- where

import Ports exposing (..)
import Maybe.Extra exposing (..)
import Msg exposing (..)
import Model.Note exposing (..)
import Model.Model as Model exposing (..)
import Model.Midi exposing (..)
import Knob
import Debug exposing (..)


updateMap :
    Model
    -> (b -> childrenModel -> ( d, Cmd e ))
    -> b
    -> (Model -> childrenModel)
    -> (d -> Model -> Model)
    -> (e -> g)
    -> ( Model, Cmd g )
updateMap model childUpdate childMsg getChild reduxor msg =
    let
        ( updatedChildModel, childCmd ) =
            childUpdate childMsg (getChild model)
    in
        ( reduxor updatedChildModel model
        , Cmd.map msg childCmd
        )


noteOnCommand : Velocity -> Int -> Cmd msg
noteOnCommand velocity midiNoteNumber =
    noteOnMessage midiNoteNumber velocity |> midiOutPort


noteOffCommand : Velocity -> Int -> Cmd msg
noteOffCommand velocity midiNoteNumber =
    noteOffMessage midiNoteNumber velocity |> midiOutPort


update : Msg -> Model -> ( Model, Cmd Msg )
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
                        Model.keyToMidiNoteNumber ( symbol, model.octave )

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

            MasterVolumeChange subMsg ->
                updateMap' Knob.update subMsg .masterVolumeKnob Model.setMasterVolume MasterVolumeChange

            OscillatorsMixChange subMsg ->
                updateMap' Knob.update subMsg .oscillatorsMixKnob Model.setOscillatorsMix OscillatorsMixChange

            Oscillator2SemitoneChange subMsg ->
                updateMap' Knob.update subMsg .oscillator2SemitoneKnob Model.setOscillator2Semitone Oscillator2SemitoneChange

            Oscillator2DetuneChange subMsg ->
                updateMap' Knob.update subMsg .oscillator2DetuneKnob Model.setOscillator2Detune Oscillator2DetuneChange

            FMAmountChange subMsg ->
                updateMap' Knob.update subMsg .fmAmountKnob Model.setFmAmount FMAmountChange

            PulseWidthChange subMsg ->
                updateMap' Knob.update subMsg .pulseWidthKnob Model.setPulseWidth PulseWidthChange

            Oscillator1WaveformChange waveform ->
                ( setOscillator1Waveform model waveform, toString waveform |> oscillator1WaveformPort )

            Oscillator2WaveformChange waveform ->
                ( setOscillator2Waveform model waveform, toString waveform |> oscillator2WaveformPort )
