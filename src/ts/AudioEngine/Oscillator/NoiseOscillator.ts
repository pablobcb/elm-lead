import { BaseOscillator } from './BaseOscillator'

export default class NoiseOscillator extends BaseOscillator {

	public type : string
	public noiseOsc : AudioBufferSourceNode

	constructor (context: AudioContext) {
		super(context)

		this.type = 'whitenoise'
	}

	_noteOn = (midiNote: any) => {
		const midiNoteKey = midiNote.toString()
		const channels = 2
		const frameCount = this.context.sampleRate * 2.0

		const myArrayBuffer =
			this.context.createBuffer(2, frameCount, this.context.sampleRate)

		for (let channel = 0; channel < channels; channel++) {
			const nowBuffering = myArrayBuffer.getChannelData(channel)
			for (let i = 0; i < frameCount; i++) {
				nowBuffering[i] = Math.random() * 2 - 1
			}
		}

		this.noiseOsc = this.context.createBufferSource()
		this.noiseOsc.buffer = myArrayBuffer
		this.noiseOsc.loop = true

		this.noiseOsc.connect(this.voiceGains[midiNoteKey])
		
		this.voices[midiNoteKey] = this.noiseOsc
	}
}
