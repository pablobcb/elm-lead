import MIDI from '../MIDI'
import CONSTANTS from '../Constants'

export default class VCA {

	public context: AudioContext

	public inputs = [] as Array<GainNode>

	constructor (context: AudioContext) {
		this.context = context
		for (let i = 0; i < 128; i++) {
			this.inputs[i] = context.createGain()
		}
	}

	public connect = (nodes: Array<AudioParam>) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.inputs[i] !== null) {
				this.inputs[i].connect(nodes[i])
			}
		}
	}

	public disconnect = (nodes: Array<AudioParam>) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.inputs[i] !== null) {
				this.inputs[i].disconnect(nodes[i])
			}
		}
	}
}
