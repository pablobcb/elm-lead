import BaseOscillator from './BaseOscillator'

interface Waveform {} // FIXME

export default class FMOscillator extends BaseOscillator {

	public detune : number
	public semitone : number
	public type : string

	constructor (context: AudioContext, waveform: string) {
		super(context)
		this.type = waveform
		this.detune = 0
		this.semitone = 0
	}

	_noteOn = (midiNote: any) => {
		const midiNoteKey = midiNote.toString()
		const osc = this.context.createOscillator()

		osc.type = this.type
		osc.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc.detune.value = this.detune + this.semitone

		osc.connect(this.voiceGains[midiNote])
		this.frequencyGains[midiNote].connect(osc.frequency)

		this.voices[midiNoteKey] = osc
	}

	setDetune = detune => {
		this.detune = detune
		for (const midiNote in this.voices) {
			if (this.voices.hasOwnProperty(midiNote)) {
				this.voices[midiNote].detune.value =
					detune + this.semitone
			}
		}
	}

	setSemitone = semitone => {
		this.semitone = semitone * 100
		for (const midiNote in this.voices) {
			if (this.voices.hasOwnProperty(midiNote)) {
				this.voices[midiNote].detune.value =
					this.detune + this.semitone
			}
		}
	}

	setWaveform = waveform => {
		for (const midiNote in this.voices) {			
			if (this.voices.hasOwnProperty(midiNote)) {
				this.voices[midiNote].type = waveform
			}
		}
		this.type = waveform
	}

	setFMGain = fmGain => {
		for (let i=0; i<128; i++) {
			this.frequencyGains[i].gain.value = fmGain
		}
	}
}
