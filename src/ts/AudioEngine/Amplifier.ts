import { ADSR, ADSRState } from './ADSR'
import MIDI from '../MIDI'

export interface AmplifierState {
	adsr: ADSRState
	masterVolume: number
}

export class Amplifier {
	public state: AmplifierState = {} as AmplifierState
	public context: AudioContext
	public adsr: ADSR
	public output: any

	constructor(context: AudioContext) {
		this.context = context

		/* amp adsr */
		this.adsr = new ADSR(this.context)

		/* AudioNode graph routing */
		this.output = this.context.createGain()
		this.output.connect(this.context.destination)
	}

	public setMasterVolumeGain = (midiValue: number) => {
		const vol = MIDI.logScaleToMax(midiValue, 1)
		this.state.masterVolume = vol
		this.output.gain.value = vol
	}

	public setState = (state: AmplifierState) => {
		this.adsr.setState(state.adsr)

		this.setMasterVolumeGain(state.masterVolume)
	}

}
