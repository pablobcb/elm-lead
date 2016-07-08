import MIDI from '../MIDI'

export default class DualMixer {

	public channel1: GainNode
	public channel2: GainNode
	private mix: number // from 0 to 1
	private context: AudioContext

	constructor(context: AudioContext) {
		this.context = context
		this.channel1 = this.context.createGain()
		this.channel2 = this.context.createGain()
	}

	public connect(node: AudioParam){
		// https://developer.mozilla.org/en-US/docs/Web/API/AudioNode/connect(AudioParam)
		// acording to the docs the type is right
		// make a PR to typings to fix this
		this.channel2.connect(node)
		this.channel2.connect(node)
	}

	public setState = (midiValue: number) => {
		const mix = MIDI.normalizeValue(midiValue)
		this.mix = mix
		this.channel1.gain.value = (1 - mix) / 2
		this.channel2.gain.value = .5 - this.channel1.gain.value
	}

}
