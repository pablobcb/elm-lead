import CONSTANTS from './Constants'

export default class Oscillator {
	constructor (context, initalWaveform) {
		this.context = context
		this.node = this.context.createGain()
		this.node.gain.value = 1
		this.oscillators = {}
		this.type = initalWaveform
		this.detune = 0
		this.semitone = 0
		this.pulseWidth = 0
		this.fmGain = 0
		this.frequencyGains = [] //this.context.createGain()
		this.oscillatorGains = []

		for(let i=0; i<128; i++) {
			this.frequencyGains[i] = this.context.createGain()
			this.oscillatorGains[i] = this.context.createGain()
		}
	}

	/*createPulseOscillator = () => {
		const pulseCurve = new Float32Array(256)
		for(let i=0; i<128; i++) {
			pulseCurve[i] = -1
			pulseCurve[i + 128] = 1
		}

		const constantOneCurve = new Float32Array(2)
		constantOneCurve[0] = 1
		constantOneCurve[1] = 1

		const node = this.context.createOscillator()
		node.type = 'sawtooth'

		const pulseShaper = this.context.createWaveShaper()
		pulseShaper.curve = pulseCurve
		node.connect(pulseShaper)

		const widthGain = this.context.createGain()
		widthGain.gain.value = 0
		node.width = widthGain.gain
		widthGain.connect(pulseShaper)

		const constantOneShaper = this.context.createWaveShaper()
		constantOneShaper.curve = constantOneCurve
		node.connect(constantOneShaper)
		constantOneShaper.connect(widthGain)

		node.setWidth = function (width) {
			node.width.value = width
		}'lowpass

		node.connect = function () {
			pulseShaper.connect.apply(pulseShaper, arguments)
			return node
		}

		node.disconnect = function () {
			pulseShaper.disconnect.apply(pulseShaper, arguments)
			return node
		}

		return node
	}*/

	frequencyFromNoteNumber = (note) => {
		return 440 * Math.pow(2, (note - 69) / 12)
	}

	panic =	() => {
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				console.log("breno")
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

		this.oscillators[midiNoteKey].stop(at)

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

		const osc = this.context.createOscillator()

		// PW
		/*const osc = this.type != 'square' ?
			this.context.createOscillator() :
			this.createPulseOscillator()

		if(this.type == 'square')
			osc.setWidth(this.pulseWidth)*/

		// OSC
		osc.type = this.type
		osc.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc.detune.value = this.detune + this.semitone
		osc.onended = () => {
			osc.disconnect(this.oscillatorGains[midiNote])
			this.frequencyGains[midiNote].disconnect(osc.frequency)
			this.oscillators[midiNoteKey].disconnect(this.node)
			delete this.oscillators[midiNoteKey]
		}

		// FM
		//const fmGain = this.context.createGain()
		//this.fmGain[midiNote].gain.value = this.fmGain
		osc.connect(this.oscillatorGains[midiNote])
		this.frequencyGains[midiNote].connect(osc.frequency)
		//this.frequencyGains[midiNoteKey] = fmGain

		osc.connect(this.node)
		osc.start(this.context.currentTime)
		this.oscillators[midiNoteKey] = osc
	}

	setDetune = (detune) => {
		this.detune = detune
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].detune.value =
					this.detune + this.semitone
			}
		}
	}

	setSemitone = (semitone) => {
		this.semitone = semitone * 100
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].detune.value =
					this.detune + this.semitone
			}
		}
	}

	setWaveform = (waveform) => {
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				/*if(waveform == 'square' || this.type == 'square') {
					this.noteOff(Number(midiNote))
					this.type = waveform
					this.noteOn(Number(midiNote))
				}*/
				this.oscillators[midiNote].type = waveform
			}
		}
		this.type = waveform
	}

	setPulseWidth = (pulseWidth) => {
		this.pulseWidth = pulseWidth
		if(this.type == CONSTANTS.WAVEFORM_TYPE.SQUARE) {
			for(const midiNote in this.oscillators) {
				if(this.oscillators.hasOwnProperty(midiNote)) {
					this.oscillators[midiNote].setWidth(this.pulseWidth)
				}
			}
		}
	}

	setFMGain = (fmGain) => {
		this.fmGain = fmGain
		for(let i=0; i<128; i++) {
			this.frequencyGains[i].gain.value = this.fmGain
			console.log(this.fmGain)
		}
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