import CONSTANTS from '../Constants'

export default class BaseOscillator {

	protected context: AudioContext
	public vcos = [] as Array<any>
	public outputs = [] as Array<GainNode>

	constructor(context: AudioContext) {
		this.context = context

		for (let i = 0; i < CONSTANTS.MAX_NOTES; i++) {
			this.vcos[i] = null
			this.outputs[i] = this.context.createGain()
		}
	}

	protected midiToFreq = (midiValue: number): number => {
		return 440 * Math.pow(2, (midiValue - 69) / 12)
	}

	//TODO: type alias at to seconds

	public noteOff = (midiNote: number, releaseTime : number) => {
		const midiNoteKey = midiNote.toString()
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
			}
		}
	}

	public connect = (nodes: Array<AudioParam>) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].connect(nodes[i])
			}
		}
	}

	public disconnect = (node: Array<AudioParam>) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].disconnect(nodes[i])
			}
		}
	}
}
