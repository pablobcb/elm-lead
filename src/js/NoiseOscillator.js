import CONSTANTS from './Constants'

export default class NoiseOscillator {
	constructor (context) {
				this.context = context
		this.node = this.context.createGain()
		this.node.gain.value = 1
		this.oscillators = {}
		this.oscillatorGains = []

		for(let i=0; i<128; i++) {
			this.frequencyGains[i] = this.context.createGain()
			this.oscillatorGains[i] = this.context.createGain()
		}
	}


	panic =	() => {
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].stop()
			}
		}
	}

	noteOff = (at, midiNote) => {
		let midiNoteKey
		
		if(midiNote)
			midiNoteKey = midiNote.toString()
		
			
		if(!(midiNoteKey in this.oscillators))
			return

		this.oscillators[midiNoteKey].stop()

		// FM
		/*this.frequency[midiNoteKey]
			.disconnect(this.oscillators[midiNoteKey].frequency)*/

		//delete this.frequency[midiNoteKey]

		// OSC
		
	}

	noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()

		if(midiNoteKey in this.oscillators)
			return

		
		const noiseOsc = this.context.createBufferSource()
		, buffer = this.context.createBuffer(1, 4096, this.context.sampleRate)
		, data = buffer.getChannelData(0)

		for (let i = 0; i < 4096; i++) {
			data[i] = Math.random()
		}

		noiseOsc.buffer = buffer
		noiseOsc.loop = true

		noiseOsc.connect(this.oscillatorGains[midiNote])


		noiseOsc.connect(this.node)
		noiseOsc.start(this.context.currentTime)
		this.oscillators[midiNoteKey] = noiseOsc
	}

	

	connect = function (node) {
		this.node.connect(node)
		return this
	}

	disconnect = function (node) {
		this.node.disconnect(node)
		return this
	}
}