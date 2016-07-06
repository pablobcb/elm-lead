import presets from './presets.json'

import MIDI from './MIDI'

const scaleMidiValue = midiValue =>
	MIDI.logScaleToMax(midiValue, 1)

export default class PresetManager {
	_ = () => { }

	constructor() {
		this.currentPresetIndex = -1
	}

	next = () => {
		// cycle through bank
		if (this.currentPreset == presets.length) {
			this.currentPresetIndex = - 1
		}

		this.currentPresetIndex += 1
		const currentPreset = presets[this.currentPresetIndex]

		// preset indexing in a bank starts from 1 instead of 0
		currentPreset.number = this.currentPresetIndex + 1

		return currentPreset
	}

	previous = () => {
		// cycle through bank
		if (this.currentPreset == presets.length) {
			this.currentPresetIndex = -1
		}

		this.currentPresetIndex += 1
		const currentPreset = presets[this.currentPresetIndex]

		// preset indexing in a bank starts from 1 instead of 0
		currentPreset.number = this.currentPresetIndex + 1

		return currentPreset
	}

	midiSettingsToSynthSettings = (preset) => {
		const state = {
			filter: {
				amp: {}
			},
			amp: {},
			oscs: {
				osc1: {},
				osc2: {}
			}
		}

		/* META */
		//displayed name
		state.name = preset.name

		/* AMP */
		state.amp.attack =
			scaleMidiValue(preset.amp.attack)

		state.amp.decay =
			scaleMidiValue(preset.amp.decay)

		state.amp.sustain =
			scaleMidiValue(preset.amp.sustain)

		state.amp.release =
			scaleMidiValue(preset.amp.release)

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

		state.filter.amp.attack =
			scaleMidiValue(preset.filter.amp.attack)

		state.filter.amp.decay =
			scaleMidiValue(preset.filter.amp.decay)

		state.filter.amp.sustain =
			scaleMidiValue(preset.filter.amp.sustain)

		state.filter.amp.release =
			scaleMidiValue(preset.filter.amp.release)

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