import CONSTANTS from './Constants'

export default class Oscillator {
	constructor (context, waveform) {
		this.context = context
		this.output = this.context.createGain()
		this.output.gain.value = 1
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

	}

	noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()

		if(midiNoteKey in this.oscillators)
			return

		const osc = this.context.createOscillator()

		osc.type = this.type
		osc.frequency.value = this.frequencyFromNoteNumber(midiNote)
		//debugger
		osc.detune.value = this.detune + this.semitone
		osc.onended = () => {
			osc.disconnect(this.oscillatorGains[midiNote])
			this.frequencyGains[midiNote].disconnect(osc.frequency)
			this.oscillators[midiNoteKey].disconnect(this.output)
			delete this.oscillators[midiNoteKey]
		}

		osc.connect(this.oscillatorGains[midiNote])
		this.frequencyGains[midiNote].connect(osc.frequency)


		osc.connect(this.output)
		osc.start(this.context.currentTime)
		this.oscillators[midiNoteKey] = osc
	}

	setDetune = (detune) => {
		this.detune = detune
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].detune.value =
					detune + this.semitone
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
				this.oscillators[midiNote].type = waveform
			}
		}
		this.type = waveform
	}



	setFMGain = (fmGain) => {
		this.fmGain = fmGain
		for(let i=0; i<128; i++) {
			this.frequencyGains[i].gain.value = this.fmGain
			console.log(this.fmGain)
		}
	}

	connect = function (node) {
		this.output.connect(node)
		return this
	}

	disconnect = function (node) {
		this.output.disconnect(node)
		return this
	}
}