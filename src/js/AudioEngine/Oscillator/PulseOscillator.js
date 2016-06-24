import BaseOscillator from './BaseOscillator'


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

		this.sawNode = this.context.createOscillator()
		this.sawNode.type = 'sawtooth'
		this.pulseShaper = this.context.createWaveShaper()
		this.pulseShaper.curve = pulseCurve
		this.sawNode.connect(this.pulseShaper)
		
		this.widthGain = this.context.createGain()
		this.widthGain.gain.value = this.pulseWidth
		this.sawNode.width = this.widthGain.gain
		
		this.widthGain.connect(this.pulseShaper)
		
		this.constantOneShaper = this.context.createWaveShaper()
		this.constantOneShaper.curve = constantOneCurve
		this.sawNode.connect(this.constantOneShaper)
		this.constantOneShaper.connect(this.widthGain)
	


		this.sawNode.frequency.value = this.frequencyFromNoteNumber(midiNote)
		this.sawNode.detune.value = this.detune + this.semitone
		
		this.pulseShaper.connect(this.oscillatorGains[midiNote])
		this.frequencyGains[midiNote].connect(this.sawNode.frequency)
		this.pulseShaper.connect(this.output)
		
		this.sawNode.start(this.context.currentTime)
		
		this.oscillators[midiNoteKey] = this.sawNode

		this.sawNode.onended = () => {		
			delete this.oscillators[midiNoteKey]
		}
		console.log(this)
	}

	setPulseWidth = (width) => {
		this.pulseWidth = width
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				console.log(midiNote)
				this.oscillators[midiNote].width = width
			}
		}	
	}

}


