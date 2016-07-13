import CONSTANTS from '../../Constants'

const noiseOscillatorFactory = {
	createNoiseOscillator: (context: AudioContext) => {
		const channels = 2
		const frameCount = context.sampleRate * 2.0

		const myArrayBuffer =
			context.createBuffer(2, frameCount, context.sampleRate)

		for (let channel = 0; channel < channels; channel++) {
			const nowBuffering = myArrayBuffer.getChannelData(channel)
			for (let i = 0; i < frameCount; i++) {
				nowBuffering[i] = Math.random() * 2 - 1
			}
		}

		const noiseOsc : AudioBufferSourceNode = context.createBufferSource()
		noiseOsc.buffer = myArrayBuffer
		noiseOsc.loop = true
		noiseOsc.frequency = { value: null }

		return noiseOsc
	}
}

export default noiseOscillatorFactory
