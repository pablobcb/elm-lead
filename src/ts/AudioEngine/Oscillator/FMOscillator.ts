import { BaseOscillator, WaveformType } from './BaseOscillator'

export default class FMOscillator extends BaseOscillator {

	public detune : number
	public semitone : number

	constructor (context: AudioContext, waveformType: WaveformType) {
		super(context, waveformType)
		this.detune = 0
		this.semitone = 0
	}

	_noteOn (midiNote: any) {
		const midiNoteKey = midiNote.toString()
		const osc = this.context.createOscillator()

		osc.type = this.type
		osc.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc.detune.value = this.detune + this.semitone

		osc.connect(this.voiceGains[midiNote])
		this.frequencyGains[midiNote].connect(osc.frequency)

		this.voices[midiNoteKey] = osc
	}

	setDetune (detune: number) {
		this.detune = detune
		for (let midiNote in this.voices) {
			if (this.voices.hasOwnProperty(midiNote)) {
				this.voices[midiNote].detune.value =
					detune + this.semitone
			}
		}
	}

	setSemitone (semitone: number) {
		this.semitone = semitone * 100
		for (let midiNote in this.voices) {
			if (this.voices.hasOwnProperty(midiNote)) {
				this.voices[midiNote].detune.value =
					this.detune + this.semitone
			}
		}
	}

	setWaveform (waveform: WaveformType) {
		for (let midiNote in this.voices) {
			if (this.voices.hasOwnProperty(midiNote)) {
				this.voices[midiNote].type = waveform
			}
		}
		this.type = waveform
	}

	setFMGain = (fmGain: number) => {
		for (let i=0; i<128; i++) {
			this.frequencyGains[i].gain.value = fmGain
		}
	}
}
