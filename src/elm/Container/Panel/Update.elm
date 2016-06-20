module Container.Panel.Update exposing (..)

--where

import Container.Panel.Model as Model exposing (..)
import Component.Knob as Knob
import Component.NordButton as Button


type Msg
    = Oscillator1WaveformChange Button.Msg
    | Oscillator2WaveformChange Button.Msg
    | Oscillator2SemitoneChange Knob.Msg
    | Oscillator2DetuneChange Knob.Msg
    | FMAmountChange Knob.Msg
    | PulseWidthChange Knob.Msg
    | OscillatorsMixChange Knob.Msg
    | FilterCutoffChange Knob.Msg
    | FilterQChange Knob.Msg
    | FilterTypeChange Button.Msg
    | MasterVolumeChange Knob.Msg
    | MouseUp
    | MouseMove Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        updateMap childUpdate childMsg getChild reduxor msg' =
            let
                ( updatedChildModel, childCmd ) =
                    childUpdate childMsg (getChild model)
            in
                ( reduxor updatedChildModel model
                , Cmd.map msg' childCmd
                )
    in
        case msg of
            MasterVolumeChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .ampVolumeKnob
                    updateAmpVolumeKnob
                    MasterVolumeChange

            OscillatorsMixChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillatorsMixKnob
                    updateOscillatorsMixKnob
                    OscillatorsMixChange

            Oscillator2SemitoneChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator2SemitoneKnob
                    updateOscillator2SemitoneKnob
                    Oscillator2SemitoneChange

            Oscillator2DetuneChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator2DetuneKnob
                    updateOscillator2DetuneKnob
                    Oscillator2DetuneChange

            FMAmountChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator1FmAmountKnob
                    updateOscillator1FmAmountKnob
                    FMAmountChange

            PulseWidthChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillatorsPulseWidthKnob
                    updatePulseWidthKnob
                    PulseWidthChange

            Oscillator1WaveformChange subMsg ->
                updateMap Button.update
                    subMsg
                    .oscillator1WaveformBtn
                    updateOscillator1WaveformBtn
                    Oscillator1WaveformChange

            Oscillator2WaveformChange subMsg ->
                updateMap Button.update
                    subMsg
                    .oscillator2WaveformBtn
                    updateOscillator2WaveformBtn
                    Oscillator2WaveformChange

            FilterCutoffChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .filterCutoffKnob
                    updateFilterCutoffKnob
                    FilterCutoffChange

            FilterQChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .filterQKnob
                    updateFilterQKnob
                    FilterQChange

            FilterTypeChange subMsg ->
                updateMap Button.update
                    subMsg
                    .filterTypeBtn
                    updateFilterTypeBtn
                    FilterTypeChange

            MouseUp ->
                ( Model.mouseUp model, Cmd.none )
            
            MouseMove yPos->
                ( Model.mouseUp model, Cmd.none )
