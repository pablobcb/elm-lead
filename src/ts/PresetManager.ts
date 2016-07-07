const presets: Array<Preset> = require('../presets.json')

import MIDI from './MIDI'
import { FilterState } from './AudioEngine/Filter'
import { AmplifierState } from './AudioEngine/Amplifier'

const scaleMidiValue = (midiValue: number) =>
	MIDI.logScaleToMax(midiValue, 1)

interface Preset {
	name: string
	presetId: number
	filter: FilterState
	amp: any
	oscs: { osc1: Object, osc2: Object }
	overdrive: boolean
}

export default class PresetManager {
	private currentPresetIndex: number

	constructor() {
		this.currentPresetIndex = -1
	}

	next = () => {
		// cycle through bank
		if (this.currentPresetIndex == presets.length - 1) {
			this.currentPresetIndex = - 1
		}

		this.currentPresetIndex += 1

		const currentPreset = presets[this.currentPresetIndex]
		// preset indexing in a bank starts from 1 instead of 0
		currentPreset.presetId = this.currentPresetIndex + 1

		return currentPreset
	}

	previous = () => {
		// cycle through bank
		this.currentPresetIndex -= 1

		if (this.currentPresetIndex == - 1) {
			this.currentPresetIndex = presets.length - 1
		}
		const currentPreset = presets[this.currentPresetIndex]

		// preset indexing in a bank starts from 1 instead of 0
		currentPreset.presetId = this.currentPresetIndex + 1
		// preset indexing in a bank starts from 1 instead of 0
		return currentPreset
	}

	midiSettingsToSynthSettings = (preset: Preset) => {
		let state: Preset
		/* META */
		//displayed name
		state.name = preset.name

		/* AMP */
		state.amp.adsr.attack =
			scaleMidiValue(preset.amp.adsr.attack)

		state.amp.adsr.decay =
			scaleMidiValue(preset.amp.adsr.decay)

		state.amp.adsr.sustain =
			scaleMidiValue(preset.amp.adsr.sustain)

		state.amp.adsr.release =
			scaleMidiValue(preset.amp.adsr.release)

		state.amp.masterVolume =
			scaleMidiValue(preset.amp.masterVolume)

		/* OVERDRIVE */
		state.overdrive =
			preset.overdrive

		/* FILTER */
		state.filter.type_ =
			preset.filter.type_

		state.filter.envelopeAmount =
			scaleMidiValue(preset.filter.envelopeAmount)

		state.filter.q =
			MIDI.toFilterQAmount(preset.filter.q)

		state.filter.frequency =
			MIDI.toFilterCutoffFrequency(preset.filter.frequency)

		state.filter.adsr.attack =
			scaleMidiValue(preset.filter.adsr.attack)

		state.filter.adsr.decay =
			scaleMidiValue(preset.filter.adsr.decay)

		state.filter.adsr.sustain =
			scaleMidiValue(preset.filter.adsr.sustain)

		state.filter.adsr.release =
			scaleMidiValue(preset.filter.adsr.release)

		/* OSC */
		state.oscs.pw =
			MIDI.logScaleToMax(preset.oscs.pw, .9)

		state.oscs.mix =
			MIDI.normalizeValue(preset.oscs.mix)

		state.oscs.osc1.waveformType =
			preset.oscs.osc1.waveformType

		state.oscs.osc1.fmGain =
			scaleMidiValue(preset.oscs.osc1.fmGain)

		state.oscs.osc2.waveformType =
			preset.oscs.osc2.waveformType

		state.oscs.osc2.semitone =
			preset.oscs.osc2.semitone

		state.oscs.osc2.detune =
			preset.oscs.osc2.detune

		state.oscs.osc2.kbdTrack =
			preset.oscs.osc2.kbdTrack

		return state
	}
}
