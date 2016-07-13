import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import { BaseOscillator } from './Oscillator/BaseOscillator'

export default class VCA {

	public context: AudioContext

	private inputs = [] as Array<GainNode>

	constructor (context: AudioContext) {
		this.context = context
		for (let i = 0; i < 128; i++) {
			this.inputs[i] = context.createGain()
		}
	}

	//public connect = (nodes: Array<AudioParam>) => {
	public connect = (node: AudioParam) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.inputs[i] !== null) {
				this.inputs[i].connect(node)
			}
		}
	}

	public disconnect = (node: AudioParam) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.inputs[i] !== null) {
				this.inputs[i].disconnect(node)
			}
		}
	}
	// TODO:
	// linear & exponential controls switch
	// mod input
	// mod amount knob/gain
}
