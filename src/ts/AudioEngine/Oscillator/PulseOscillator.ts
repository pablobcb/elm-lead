import FMOscillator from './FMOscillator'
import CONSTANTS from '../../Constants'

const pulseCurve = new Float32Array(256)
for (let i=0;i<128;i++) {
	pulseCurve[i] = -1
	pulseCurve[i+128] =1
}

const constantOneCurve = new Float32Array(2)
constantOneCurve[0] = 1
constantOneCurve[1] = 1

export default class PulseOscillator extends FMOscillator {

	public pulseWidth : number
	public pulseShaper : WaveShaperNode
	public widthGains : Array<GainNode>

	constructor (context: AudioContext) {
		super(context, 'pulse')
		this.pulseWidth = 0
		this.widthGains = []


		for (let i = 0; i < 128; i++) {
			this.widthGains[i] = this.context.createGain()
		}
	}

	_noteOn = (midiNote: number) => {
		const midiNoteKey = midiNote.toString()

		const sawNode = this.context.createOscillator()
		sawNode.type = CONSTANTS.WAVEFORM_TYPE.SAWTOOTH

		this.pulseShaper = this.context.createWaveShaper()
		this.pulseShaper.curve = pulseCurve
		sawNode.connect(this.pulseShaper)

		const widthGain = this.widthGains[midiNote]
		widthGain.gain.value = this.pulseWidth

		widthGain.connect(this.pulseShaper)

		const constantOneShaper = this.context.createWaveShaper()
		constantOneShaper.curve = constantOneCurve
		sawNode.connect(constantOneShaper)
		constantOneShaper.connect(widthGain)

		sawNode.frequency.value = this.frequencyFromNoteNumber(midiNote)
		sawNode.detune.value = this.detune + this.semitone

		this.pulseShaper.connect(this.voiceGains[midiNote])

		this.voices[midiNoteKey] = sawNode
	}

	_onended = () => {
		this.pulseShaper.disconnect()
	}

	setPulseWidth = (width: any) => {
		this.pulseWidth = width
		this.widthGains.forEach(widthGain => {
			widthGain.gain.value = width
		})
	}
}
