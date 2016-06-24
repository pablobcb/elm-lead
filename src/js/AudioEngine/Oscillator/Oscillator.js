import BaseOscillator from './BaseOscillator'


export default class Oscillator extends BaseOscillator {
	constructor (context, waveform) {
		super(context)
		this.type = waveform
		this.detune = 0
		this.semitone = 0
	}

	_ = () => {}
	
	noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()

		if(midiNoteKey in this.oscillators)
			return

		const osc = this.context.createOscillator()

		osc.type = this.type
		osc.frequency.value = this.frequencyFromNoteNumber(midiNote)
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
		for(let i=0; i<128; i++) {
			this.frequencyGains[i].gain.value = fmGain
		}
	}

}