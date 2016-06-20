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
                    setAmpVolumeKnob
                    MasterVolumeChange

            OscillatorsMixChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillatorsMixKnob
                    setOscillatorsMixKnob
                    OscillatorsMixChange

            Oscillator2SemitoneChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator2SemitoneKnob
                    setOscillator2SemitoneKnob
                    Oscillator2SemitoneChange

            Oscillator2DetuneChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator2DetuneKnob
                    setOscillator2DetuneKnob
                    Oscillator2DetuneChange

            FMAmountChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillator1FmAmountKnob
                    setOscillator1FmAmountKnob
                    FMAmountChange

            PulseWidthChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .oscillatorsPulseWidthKnob
                    setPulseWidthKnob
                    PulseWidthChange

            Oscillator1WaveformChange subMsg ->
                updateMap Button.update
                    subMsg
                    .oscillator1WaveformBtn
                    setOscillator1WaveformBtn
                    Oscillator1WaveformChange

            Oscillator2WaveformChange subMsg ->
                updateMap Button.update
                    subMsg
                    .oscillator2WaveformBtn
                    setOscillator2WaveformBtn
                    Oscillator2WaveformChange

            FilterCutoffChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .filterCutoffKnob
                    setFilterCutoffKnob
                    FilterCutoffChange

            FilterQChange subMsg ->
                updateMap Knob.update
                    subMsg
                    .filterQKnob
                    setFilterQKnob
                    FilterQChange

            FilterTypeChange subMsg ->
                updateMap Button.update
                    subMsg
                    .filterTypeBtn
                    setFilterTypeBtn
                    FilterTypeChange

            MouseUp ->
                ( model, Cmd.none )
