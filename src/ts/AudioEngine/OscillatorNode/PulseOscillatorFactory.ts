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
	createPulseOscillator: (context: AudioContext, widthGain: any) => {
	//createPulseOscillator: (context: AudioContext, widthGain: GainNode) => {
		const sawNode: OscillatorNode = context.createOscillator()
		sawNode.type = CONSTANTS.WAVEFORM_TYPE.SAWTOOTH

		const pulseShaper: WaveShaperNode = context.createWaveShaper()
		pulseShaper.curve = pulseCurve
		sawNode.connect(pulseShaper)

		const constantOneShaper = context.createWaveShaper()
		constantOneShaper.curve = constantOneCurve
		sawNode.connect(constantOneShaper)
		constantOneShaper.connect(widthGain)

		//sawNode.connect = (node : AudioParam) => {
		sawNode.connect = (destination : any) => {
			pulseShaper.connect(destination)
			widthGain.connect(pulseShaper)
		}

		sawNode.disconnect = () => {
			pulseShaper.disconnect()
			widthGain.disconnect()
			constantOneShaper.disconnect()
		}

		//sawNode.onended = () => {
		//	sawNode.disconnect()
		//}

		return sawNode
	}
}

export default pulseOscillatorFactory