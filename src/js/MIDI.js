// all midi values are integers between 0 and 127

const MIDI_MAX_VALUE = 127

const midiToFreq = (midiValue) => (
	440 * Math.pow(2, (midiValue - 69) / 12)
)

const manageMidiDevices = (
	onMIDIMessage, 
	midiAccess,
	midiPort,
	midiStateChangePort
	) => 
{
	let midiConnection = false	
	// loop over all available inputs and listen for any MIDI input
	for (const input of midiAccess.inputs.values()) {
		input.onmidimessage = (midiMessage) => {
			const data = midiMessage.data

			onMIDIMessage(data)
			midiPort.send([
				data[0],
				data[1] || null,
				data[2] || null
			])
		}
		if(input.manufacturer !== '') {
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

	toFilterQAmount : midiValue => (
		20 * (midiValue / MIDI_MAX_VALUE)
	),

	toFilterCutoffFrequency : midiValue => (
		1.6 * midiToFreq(midiValue)
	),

	logScaleToMax : (midiValue, max) => (
		(Math.pow(2, midiValue / MIDI_MAX_VALUE) - 1) * max
	),

	normalizeValue : midiValue => (
		midiValue / MIDI_MAX_VALUE
	),

	manageMidiDevices : (
		onMIDIMessage, 
		midiAccess, 
		midiPort, 
		midiStateChange) => 
	{
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