export default class NoiseOscillator {
	constructor (context) {
		this.context = context
		this.node = this.context.createGain()
		this.node.gain.value = .5
		this.oscillators = {}
		this.oscillatorGains = []
		this.frequencyGains = []
		this.type = 'whitenoise'

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
	}

	noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()

		if(midiNoteKey in this.oscillators)
			return

		
		const channels = 2
		// Create an empty two-second stereo buffer at the
		// sample rate of the AudioContext
		const frameCount = this.context.sampleRate * 2.0

		const myArrayBuffer = this.context
			.createBuffer(2, frameCount, this.context.sampleRate)


		for (let channel = 0; channel < channels; channel++) {
			// This gives us the actual ArrayBuffer that contains the data
			const nowBuffering = myArrayBuffer.getChannelData(channel)
			for (let i = 0; i < frameCount; i++) {
				// Math.random() is in [0; 1.0]
				// audio needs to be in [-1.0; 1.0]
				nowBuffering[i] = Math.random() * 2 - 1
			}
		}

		


		const noiseOsc = this.context.createBufferSource()
		noiseOsc.onended = () => {
			noiseOsc.disconnect(this.oscillatorGains[midiNote])
			noiseOsc.disconnect(this.frequencyGains[midiNote].gain)
			//this.oscillators[midiNoteKey].disconnect(this.node)
			delete this.oscillators[midiNoteKey]
		}

		noiseOsc.buffer = myArrayBuffer
		noiseOsc.loop = true

		const gain = this.oscillatorGains[midiNoteKey]
		noiseOsc.connect(gain)
		noiseOsc.connect(this.frequencyGains[midiNote].gain)
		gain.connect(this.node)
		noiseOsc.start(this.context.currentTime)
		this.oscillators[midiNoteKey] = noiseOsc
	
	}

	setSemitone = () => {}

	setDetune = () => {}	

	connect = function (node) {
		this.node.connect(node)
		return this
	}

	disconnect = function (node) {
		this.node.disconnect(node)
		return this
	}
}