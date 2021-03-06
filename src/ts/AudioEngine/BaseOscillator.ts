import CONSTANTS from '../Constants'
import MIDI from '../MIDI'

export default class BaseOscillator {

	public context: AudioContext
	public vcos = [] as Array<any>
	//public outputs = [] as Array<GainNode>
	public outputs = [] as Array<any>

	constructor(context: AudioContext) {
		this.context = context

		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.vcos[i] = null
			this.outputs[i] = this.context.createGain()
		}
	}

	public noteOff (midiNote: number, releaseTime : number) {
		MIDI.validateValue(midiNote)
		const vco = this.vcos[midiNote]

		if (!vco) {
			return
		}

		vco.stop(releaseTime)
	}

	public panic = () => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.vcos[i] !== null) {
				this.vcos[i].stop()
				this.vcos[i] = null
			}
		}
	}

	//public connect = (nodes: Array<AudioParam>) => {
	public connect = (nodes: any) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].connect(nodes[i])
			}
		}
	}

	//public disconnect = (nodes: Array<AudioParam>) => {
	public disconnect = (nodes: any) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].disconnect(nodes[i])
			}
		}
	}
}
