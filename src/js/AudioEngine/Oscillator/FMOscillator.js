import BaseOscillator from './BaseOscillator'

export default class FMOscillator extends BaseOscillator {
	constructor (context, waveform) {
		super(context)
		this.type = waveform
		this.detune = 0
		this.semitone = 0
	}

	//shutup visual studio
	_ = () => {}
	
	_noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()
		const osc = this.context.createOscillator()

		osc.type = this.type
		osc.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc.detune.value = this.detune + this.semitone

		osc.connect(this.oscillatorGains[midiNote])
		this.frequencyGains[midiNote].connect(osc.frequency)

		this.oscillators[midiNoteKey] = osc
	}

	setDetune = (detune) => {
		this.detune = detune
		for (const midiNote in this.oscillators) {
			if (this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].detune.value = detune + this.semitone
			}
		}
	}

	setSemitone = (semitone) => {
		this.semitone = semitone * 100
		for (const midiNote in this.oscillators) {
			if (this.oscillators.hasOwnProperty(midiNote)) {
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
