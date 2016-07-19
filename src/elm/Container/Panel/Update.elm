module Container.Panel.Update exposing (Msg(..), update)

--where

import Container.Panel.Model as Model exposing (Model)
import Component.Knob as Knob
import Component.Switch as Switch
import Component.OptionPicker as OptionPicker


type Msg
    = Osc1WaveformChange OptionPicker.Msg
    | Osc2WaveformChange OptionPicker.Msg
    | Osc2KbdTrackToggle Switch.Msg
    | OverdriveToggle Switch.Msg
    | FilterTypeChange OptionPicker.Msg
    | Lfo1DestinationChange OptionPicker.Msg
    | Lfo1WaveformChange OptionPicker.Msg
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
                    Model.updateOsc1WaveformBtn
                    Osc1WaveformChange

            Osc2WaveformChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .osc2WaveformBtn
                    Model.updateOsc2WaveformBtn
                    Osc2WaveformChange

            FilterTypeChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .filterTypeBtn
                    Model.updateFilterTypeBtn
                    FilterTypeChange

            Lfo1DestinationChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .lfo1DestinationBtn
                    Model.updateLfo1DestinationBtn
                    Lfo1DestinationChange

            Lfo1WaveformChange subMsg ->
                updateMap OptionPicker.update
                    subMsg
                    .lfo1WaveformBtn
                    Model.updateLfo1WaveformBtn
                    Lfo1WaveformChange

            Osc2KbdTrackToggle subMsg ->
                updateMap Switch.update
                    subMsg
                    .osc2KbdTrackSwitch
                    Model.updateOsc2KbdTrack
                    Osc2KbdTrackToggle

            OverdriveToggle subMsg ->
                updateMap Switch.update
                    subMsg
                    .overdriveSwitch
                    Model.updateOverdriveSwitch
                    OverdriveToggle

            KnobMsg subMsg ->
                updateKnobs subMsg (KnobMsg subMsg)
