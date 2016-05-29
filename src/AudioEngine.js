import utils from './utils.js'

export default class AudioEngine {

	context = new AudioContext

	oscillators = []

	constructor (midiAccess) {
		this.initializeMidiAccess(midiAccess)
		this.initializeMasterVolume()
	}

	initializeMidiAccess (midiAccess) {
		// when we get a succesful response, run this code
		let inputs = midiAccess.inputs.values()

		// iterate through the devices
		let input = inputs.next()
		for (; input && !input.done; input = inputs.next()) {
			console.log(input.value)
		}

		// this is our raw MIDI data, inputs, outputs, and sysex status
		const midi = midiAccess

		inputs = midi.inputs.values()
		// loop over all available inputs and listen for any MIDI input
		input = inputs.next()
		for (; input && !input.done; input = inputs.next()) {
			// each time there is a midi message call the onMIDIMessage
			// function
			input.value.onmidimessage = this.onMIDIMessage
		}
	}

	initializeMasterVolume () {
		this.masterVolume = this.context.createGain()
		this.masterVolume.gain.value = 0.2
		this.masterVolume.connect(this.context.destination)
	}

	onMIDIMessage (event) {
		const data = event.data
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf

		// channel agnostic message type. Thanks, Phil Burk.
		const type = data[0] & 0xf0

		const note = data[1]
		const velocity = data[2]

		switch (type) {
			case 144: // noteOn message
				this.noteOn(note, velocity)
				break
			case 128: // noteOff message
				this.noteOff(note, velocity)
				break
		}

		// logger("breno", 'key data', data);
	}

	noteOn (midiNote) {
		const osc1 = this.context.createOscillator()
		this.oscillators[midiNote] = [osc1]

		osc1.frequency.value = utils.frequencyFromNoteNumber(midiNote)
		osc1.type = 'sine'
		osc1.connect(this.masterVolume)
		osc1.start(this.context.currentTime)
	}

	noteOff (midiNote, velocity) {
		console.log(midiNote, velocity)
	}

}
