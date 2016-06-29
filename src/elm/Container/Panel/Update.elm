module Container.Panel.Update exposing (..)

--where

import Container.Panel.Model as Model exposing (..)
import Component.Knob as Knob
import Component.Switch as Switch
import Component.OptionPicker as OptionPicker


type Msg
    = Osc1WaveformChange OptionPicker.Msg
    | Osc2WaveformChange OptionPicker.Msg
    | Osc2KbdTrackToggle Switch.Msg
    | FilterDistortionToggle Switch.Msg
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
            Osc1WaveformChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .osc1WaveformBtn
                    updateOsc1WaveformBtn
                    Osc1WaveformChange

            Osc2WaveformChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .osc2WaveformBtn
                    updateOsc2WaveformBtn
                    Osc2WaveformChange

            FilterTypeChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .filterTypeBtn
                    updateFilterTypeBtn
                    FilterTypeChange

            Osc2KbdTrackToggle subMsg ->
                updateMap Switch.update
                    subMsg
                    .osc2KbdTrackSwitch
                    updateOsc2KbdTrack
                    Osc2KbdTrackToggle

            FilterDistortionToggle subMsg ->
                updateMap Switch.update
                    subMsg
                    .filterDistortionSwitch
                    updateFilterDistortionSwitch
                    FilterDistortionToggle

            KnobMsg subMsg ->
                updateKnobs subMsg (KnobMsg subMsg)
