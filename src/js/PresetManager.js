import preset from './preset.json'

import MIDI from './MIDI'

const scaleMidiValue = midiValue =>
	MIDI.logScaleToMax(midiValue, 1)

export default {
	loadPreset: () => preset,

	midiSettingsToSynthSettings: () => {
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
		// AMP
		state.amp.attack =
			scaleMidiValue(preset.amp.attack)

		state.amp.decay =
			scaleMidiValue(preset.amp.decay)

		state.amp.sustain =
			scaleMidiValue(preset.amp.sustain)

		state.amp.release =
			scaleMidiValue(preset.amp.release)

		state.masterVolume = 
			scaleMidiValue(preset.masterVolume)

		//FILTER
		state.filter.type_ =
			preset.filter.type_

		state.filter.distortion =
			preset.filter.distortion

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

		//OSC
		state.oscs.pw =
			scaleMidiValue(preset.oscs.pw)
		
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