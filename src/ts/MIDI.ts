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
		for (let input of midiAccess.inputs.values()) {
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
	validateValue: (midiValue: number) => {
		if (midiValue < 0 || midiValue > 127) {
			throw new Error(`"midiValue" should be between 0 and 127,
			got: ${midiValue}`)
		}
	},

	toFrequency: midiToFreq,

	logScaleToMax: (midiValue: number, max: number) => (
		(Math.pow(2, midiValue / MIDI_MAX_VALUE) - 1) * max
	),

	normalizeValue: (midiValue: number) => (
		midiValue / MIDI_MAX_VALUE
	),

	manageMidiDevices:
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
