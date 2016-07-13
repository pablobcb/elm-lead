import MIDI from '../MIDI'
import CONSTANTS from '../Constants'

export default class DualMixer {

	public channel1 = [] as Array<GainNode>
	public channel2 = [] as Array<GainNode>
	private mix: number // from 0 to 1
	private context: AudioContext

	constructor(context: AudioContext) {
		this.context = context
		for(let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.channel1[i] = this.context.createGain()
			this.channel2[i] = this.context.createGain()
		}
	}

	public connect = (nodes: Array<AudioParam>) => {
		// https://developer.mozilla.org/en-US/docs/Web/API/AudioNode/connect(AudioParam)
		// acording to the docs the type is right
		// make a PR to typings to fix this
		for(let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.channel1[i].connect(nodes[i])
			this.channel2[i].connect(nodes[i])
		}
	}

	public setState = (midiValue: number) => {
		const mix = MIDI.normalizeValue(midiValue)
		this.mix = mix

		for(let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.channel1[i].gain.value = (1 - mix) / 2
			this.channel2[i].gain.value = .5 - this.channel1[i].gain.value
		}
	}

}
