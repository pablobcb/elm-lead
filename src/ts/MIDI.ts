// all midi values are integers between 0 and 127
const MIDI_MAX_VALUE = 127

const midiToFreq = (midiValue: number) => (
	440 * Math.pow(2, (midiValue - 69) / 12)
)

const manageMidiDevices =
	// FIXME: type that shit
	(onMIDIMessage: any, midiAccess: any, midiPort: any, midiStateChangePort: any) => {
		let midiConnection = false
		// loop over all available inputs and listen for any MIDI input
		for (const input of midiAccess.inputs.values()) {
			input.onmidimessage = (midiMessage: any) => {
				const data = midiMessage.data

				onMIDIMessage(data)
				midiPort.send([
					data[0],
					data[1] || null,
					data[2] || null
				])
			}
			if (input.manufacturer !== '') {
				midiConnection = true
			}
		}

		// this pernicious hack is necessary, see
		// https://github.com/elm-lang/core/issues/595
		setTimeout(() => midiStateChangePort.send(midiConnection), 0)

		//console.log("mandei", midiConnection)
	}

export default {

	// functions below scales midi values to synth parameters
	toOscPitch : midiToFreq,

	toFilterQAmount : (midiValue: number) => (
		20 * (midiValue / MIDI_MAX_VALUE)
	),

	toFilterCutoffFrequency : (midiValue: number) => {
		return 1.6 * midiToFreq(midiValue)
		//midiValue / 127 *
		//	(CONSTANTS.MAX_FILTER_FREQUENCY - CONSTANTS.MIN_FILTER_FREQUENCY) +
		//	CONSTANTS.MIN_FILTER_FREQUENCY
	},

	logScaleToMax : (midiValue: number, max: number) => (
		(Math.pow(2, midiValue / MIDI_MAX_VALUE) - 1) * max
	),

	normalizeValue : (midiValue: number) => (
		midiValue / MIDI_MAX_VALUE
	),

	manageMidiDevices :
		(onMIDIMessage: any, midiAccess: any, midiPort: any, midiStateChange: any) => {

			midiAccess.onstatechange = () => {
				manageMidiDevices(onMIDIMessage,
					midiAccess,
					midiPort,
					midiStateChange
				)
			}

			manageMidiDevices(onMIDIMessage,
				midiAccess,
				midiPort,
				midiStateChange
			)
		}
}
