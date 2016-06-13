module Update exposing (..)

-- where

import Ports exposing (..)
import Msg exposing (..)
import Model.Model as Model exposing (..)
import Components.OnScreenKeyboard as OnScreenKeyboard
import Components.Knob as Knob
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


update : Msg.Msg -> Model.Model -> ( Model.Model, Cmd Msg.Msg )
update msg model =
    let
        updateMap' =
            updateMap model
    in
        case msg of
            OnScreenKeyboardMsg subMsg ->
                updateMap' OnScreenKeyboard.update subMsg .onScreenKeyboard Model.setOnScreenKeyboard OnScreenKeyboardMsg

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