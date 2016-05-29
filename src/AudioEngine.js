import utils from './utils.js'

export default class AudioEngine {

	context = new AudioContext

	oscillators = []

	constructor (midiAccess : MIDIAccess) {
		this.initializeMidiAccess(midiAccess)
		this.initializeMasterVolume()
	}

	initializeMidiAccess (midiAccess : MIDIAccess) {
		// loop over all available inputs and listen for any MIDI input
		for (const input of midiAccess.inputs.values()) {
			console.log(input.value)
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

	onMIDIMessage (event : Event) {
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
	}

	noteOn = (message : Object) => {
		const { note } = message

		const osc1 = this.context.createOscillator()
		this.oscillators[note] = [osc1]

		osc1.frequency.value = utils.frequencyFromNoteNumber(note)
		osc1.type = 'sine'
		osc1.connect(this.masterVolume)
		osc1.start(this.context.currentTime)
	}

	noteOff = (midiNote : number, velocity : number) => {
		console.log(midiNote, velocity)
	}

}
