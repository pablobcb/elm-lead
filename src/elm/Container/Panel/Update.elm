module Container.Panel.Update exposing (..)

--where

import Container.Panel.Model as Model exposing (..)
import Component.Knob as Knob
import Component.OptionPicker as OptionPicker


type Msg
    = Oscillator1WaveformChange OptionPicker.Msg
    | Oscillator2WaveformChange OptionPicker.Msg
    | FilterTypeChange OptionPicker.Msg
    | KnobMsg Knob.Msg


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

        updateKnobs : Knob.Msg -> Msg -> ( Model, Cmd Msg )
        updateKnobs knobMsg msg' =
            let
                ( knobs, cmds ) =
                    List.unzip
                        <| List.map
                            --(Knob.update << knobMsg)
                            (\knob -> Knob.update knobMsg knob)
                            model.knobs
            in
                ( { model | knobs = knobs }
                , Cmd.map (always msg') <| Cmd.batch cmds
                )
    in
        case msg of
            Oscillator1WaveformChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .oscillator1WaveformBtn
                    updateOscillator1WaveformBtn
                    Oscillator1WaveformChange

            Oscillator2WaveformChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .oscillator2WaveformBtn
                    updateOscillator2WaveformBtn
                    Oscillator2WaveformChange

            FilterTypeChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .filterTypeBtn
                    updateFilterTypeBtn
                    FilterTypeChange

            KnobMsg subMsg ->
                updateKnobs subMsg (KnobMsg subMsg)
