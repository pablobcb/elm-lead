import FMOscillator from './FMOscillator'
import CONSTANTS from '../../Constants'

const pulseCurve = new Float32Array(256)
for (let i = 0; i < 128; i++) {
	pulseCurve[i] = -1
	pulseCurve[i + 128] = 1
}

const constantOneCurve = new Float32Array(2)
constantOneCurve[0] = 1
constantOneCurve[1] = 1

const pulseOscillatorFactory = {
	createPulseOscillator: (context: AudioContext, widthGain: GainNode) => {
		let pulseShaper: WaveShaperNode
		let frequency: { value: number }
		let detune: { value: number }
		let semitone: { value: number }

		const sawNode: OscillatorNode = context.createOscillator()
		sawNode.type = CONSTANTS.WAVEFORM_TYPE.SAWTOOTH

		pulseShaper = context.createWaveShaper()
		pulseShaper.curve = pulseCurve
		sawNode.connect(pulseShaper)

		//widthGain.gain.value = pulseWidth

		widthGain.connect(pulseShaper)

		const constantOneShaper = context.createWaveShaper()
		constantOneShaper.curve = constantOneCurve
		sawNode.connect(constantOneShaper)
		constantOneShaper.connect(widthGain)

		sawNode.connect = (node : AudioParam) => {
			pulseShaper.connect(node)
		}

		sawNode.disconnect = (node : AudioParam) => {
			pulseShaper.disconnect(node)
		}

		sawNode.onended = () => {
			pulseShaper.disconnect()
		}

		return sawNode
	}
}

export default pulseOscillatorFactory