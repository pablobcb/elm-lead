/**
 * AudioEngine.js
 * @flow
 */

type DOMHighResTimeStamp = any;

interface MIDIMessageEvent extends Event {
	receivedTime: DOMHighResTimeStamp;
	data: Uint8Array;
}

interface MIDIInputMap {
	values(): any
}

interface MIDIOutputMap {
}

interface MIDIAccess {
    inputs: MIDIInputMap;
    outputs: MIDIOutputMap;
    onstatechange: EventHandler;
    sysexEnabled: bool;
}


export default class AudioEngine {

	context : AudioContext;

	masterVolume : GainNode;

	oscillators : Array<Array<OscillatorNode>>;

	constructor (midiAccess : MIDIAccess) {
		this.context = new AudioContext
		this.oscillators = []
		this.initializeMidiAccess(midiAccess)
		this.initializeMasterVolume()
		this.initializeOscillatorsGain ()
		this.oscillator1Detune = 0
		this.oscillator2Detune = 0
	}

	initializeMidiAccess (midiAccess : MIDIAccess) {
		// loop over all available inputs and listen for any MIDI input
		for (const input of midiAccess.inputs.values()) {
			input.onmidimessage = this.onMIDIMessage.bind(this)
		}
	}

	initializeMasterVolume () {
		this.masterVolume = this.context.createGain()
		this.masterVolume.gain.value = 0.7
		this.masterVolume.connect(this.context.destination)
	}

	initializeOscillatorsGain () {
		this.oscillator1Gain = this.context.createGain()
		this.oscillator1Gain.gain.value = 1
		this.oscillator1Gain.connect(this.masterVolume)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = 1
		this.oscillator2Gain.connect(this.masterVolume)
	}

	onMIDIMessage (event : MIDIMessageEvent) {
		const data = event.data
		console.log(event)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf

		// channel agnostic message type
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

	frequencyFromNoteNumber (note : number) : number {
		return 440 * Math.pow(2, (note - 69) / 12)
	}

	balanceToGains (balance : number) : Array<number> {
		let osc1Gain = 1
		let osc2Gain = 1
		const gainPercentage = Math.abs(balance - 50) / 50

		if(balance < 50)
			osc1Gain -= gainPercentage
		else if(balance > 50)
			osc2Gain -= gainPercentage

		return [osc1Gain, osc2Gain]
	}

	noteOn (midiNote : number, velocity : number) {
		if(this.oscillators[midiNote])
			return

		const osc1 = this.context.createOscillator()
		const osc2 = this.context.createOscillator()

		osc1.type = 'square'
		osc1.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc1.detune.value = this.oscillator1Detune

		osc1.connect(this.oscillator1Gain)

		osc2.type = 'triangle'
		osc2.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc2.detune.value = this.oscillator2Detune

		osc2.connect(this.oscillator2Gain)

		osc1.start(this.context.currentTime)
		osc2.start(this.context.currentTime)

		this.oscillators[midiNote] = [osc1, osc2]
	}

	noteOff (midiNote : number, velocity : number) {
		this.oscillators[midiNote].forEach(oscillator => {
			oscillator.stop(this.context.currentTime)
		})

		this.oscillators[midiNote] = null
	}

	setMasterVolumeGain (masterVolumeGain : number) {
		this.masterVolume.gain.value = masterVolumeGain / 100
	}

	setOscillatorsBalance (oscillatorsBalance : number) {
		const gains = this.balanceToGains(oscillatorsBalance)

		console.log(gains)
		this.oscillator1Gain.gain.value = gains[0]
		this.oscillator2Gain.gain.value = gains[1]
	}

	setOscillator1Detune (oscillatorDetune : number) {
		this.oscillator1Detune = oscillatorDetune

		this.oscillators.forEach(oscillator => {
			if(oscillator)
				oscillator[0].detune.value = this.oscillator1Detune
		})
	}

	setOscillator2Detune (oscillatorDetune : number) {
		this.oscillator2Detune = oscillatorDetune

		this.oscillators.forEach(oscillator => {
			if(oscillator)
				oscillator[1].detune.value = this.oscillator2Detune
		})
	}

}
