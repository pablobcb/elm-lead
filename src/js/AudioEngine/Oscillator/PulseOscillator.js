import Oscillator from './Oscillator'
import CONSTANTS from '../../Constants'

const pulseCurve = new Float32Array(256)
for(let i=0;i<128;i++) {
	pulseCurve[i] = -1
	pulseCurve[i+128] =1
}

const constantOneCurve = new Float32Array(2)
constantOneCurve[0] = 1
constantOneCurve[1] = 1

export default class PulseOscillator extends Oscillator {
	constructor (context) {
		super(context, 'pulse')
		this.pulseWidth = 0
		this.widthGains = []


		for(let i = 0; i < 128; i++) {
			this.widthGains[i] = this.context.createGain()
		}
	}

	noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()

		if (midiNoteKey in this.oscillators) {
			console.log(this.oscillators)
			return
		}

		const sawNode = this.context.createOscillator()
		sawNode.type = CONSTANTS.WAVEFORM_TYPE.SAWTOOTH

		const pulseShaper = this.context.createWaveShaper()
		pulseShaper.curve = pulseCurve
		sawNode.connect(pulseShaper)

		const widthGain = this.widthGains[midiNote]
		widthGain.gain.value = this.pulseWidth

		widthGain.connect(pulseShaper)

		const constantOneShaper = this.context.createWaveShaper()
		constantOneShaper.curve = constantOneCurve
		sawNode.connect(constantOneShaper)
		constantOneShaper.connect(widthGain)

		//move kbdtrack to base oscillator
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

		this.widthGains.forEach(widthGain => {
			widthGain.gain.value = width
		})
	}
}
