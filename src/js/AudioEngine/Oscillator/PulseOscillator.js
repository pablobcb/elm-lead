import BaseOscillator from './BaseOscillator'
import CONSTANTS from '../../Constants'


const pulseCurve = new Float32Array(256)
for(let i=0;i<128;i++) {
	pulseCurve[i] = -1
	pulseCurve[i+128] =1
}

const constantOneCurve = new Float32Array(2)
constantOneCurve[0] = 1
constantOneCurve[1] = 1

export default class PulseOscillator extends BaseOscillator {
	constructor (context) {
		super(context)
		this.type = 'pulse'
		this.detune = 0
		this.semitone = 0
		this.pulseWidth = 0
		this.fmGain = 0
		this.widthGain = this.context.createGain()

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

	setFMGain = (fmGain) => {
		this.fmGain = fmGain
		for(let i=0; i<128; i++) {
			this.frequencyGains[i].gain.value = this.fmGain
			console.log(this.fmGain)
		}
	}

	noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()

		if(midiNoteKey in this.oscillators){
			console.log(this.oscillators)
			return
		}

		const sawNode = this.context.createOscillator()
		sawNode.type = CONSTANTS.WAVEFORM_TYPE.SAWTOOTH

		const pulseShaper = this.context.createWaveShaper()
		pulseShaper.curve = pulseCurve
		sawNode.connect(pulseShaper)
		
		
		this.widthGain.gain.value = this.pulseWidth
		//debugger
		//sawNode.width = this.widthGain.gain
		
		this.widthGain.connect(pulseShaper)
		
		const constantOneShaper = this.context.createWaveShaper()
		constantOneShaper.curve = constantOneCurve
		sawNode.connect(constantOneShaper)
		constantOneShaper.connect(this.widthGain)


		sawNode.frequency.value = this.frequencyFromNoteNumber(midiNote)
		sawNode.detune.value = this.detune + this.semitone
		
		pulseShaper.connect(this.oscillatorGains[midiNote])
		this.frequencyGains[midiNote].connect(sawNode.frequency)
		pulseShaper.connect(this.output)
		
		sawNode.start(this.context.currentTime)
		
		this.oscillators[midiNoteKey] = sawNode

		sawNode.onended = () => {		
			delete this.oscillators[midiNoteKey]
		}
	}

	setPulseWidth = (width) => {
		this.pulseWidth = width
		
		if(this.widthGain){
			this.widthGain.gain.value = width
		}
	}

}


