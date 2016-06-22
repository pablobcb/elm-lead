import CONSTANTS from './Constants'

export default class Oscillator {
	constructor (context, waveform) {
		this.context = context
		this.node = this.context.createGain()
		this.node.gain.value = 1
		this.oscillators = {}
		this.type = waveform
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

	frequencyFromNoteNumber = (note) => {
		return 440 * Math.pow(2, (note - 69) / 12)
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