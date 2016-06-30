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
	
	noteOn = (midiNote, noteOnCB) => {
		const midiNoteKey = midiNote.toString()
		const now = this.context.currentTime

		if (midiNoteKey in this.oscillators) {
			this.oscillators[midiNoteKey]
				.stop(now)
			this.oscillators[midiNoteKey]
				.disconnect(this.oscillatorGains[midiNote])
			this.frequencyGains[midiNote]
				.disconnect(this.oscillators[midiNoteKey].frequency)
			
			delete this.oscillators[midiNoteKey]
		} 

		const osc = this.context.createOscillator()

		osc.type = this.type
		osc.frequency.value = this.frequencyFromNoteNumber(midiNote)

		osc.detune.value = this.detune + this.semitone
		osc.onended = () => {			
			//osc.disconnect(this.oscillatorGains[midiNote])
			//this.frequencyGains[midiNote].disconnect(osc.frequency)
			delete this.oscillators[midiNoteKey]		

			console.log("ended", this.oscillators[midiNoteKey])
			
		}

		osc.connect(this.oscillatorGains[midiNote])
		this.frequencyGains[midiNote].connect(osc.frequency)

		osc.start(this.context.currentTime)

		noteOnCB(this.oscillatorGains[midiNote].gain)

		this.oscillators[midiNoteKey] = osc

		console.log("on", this.oscillators[midiNoteKey])
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
