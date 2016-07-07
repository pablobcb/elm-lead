import { ADSR,  ADSRState } from './ADSR'
import MIDI from '../MIDI'

export interface AmplifierState {
	adsr : ADSRState
	masterVolume: number
}

export class Amplifier {
	public state : AmplifierState
	public context : AudioContext
	public adsr : ADSR
	public output : GainNode

	constructor (context: AudioContext, state: AmplifierState) {
		this.context = context

		/* amp adsr state */
		this.adsr = new ADSR(this.context, state.adsr)

		/* AudioNode graph routing */
		this.output = this.context.createGain()
		this.output.connect(this.context.destination)

		this._setState(state)
	}

	setMasterVolumeGain = (midiValue: number) => {
		const vol = MIDI.logScaleToMax(midiValue, 1)
		this.state.masterVolume = vol
		this.output.gain.value = vol
	}

	_setState = (state: AmplifierState) => {
		this.output.gain.value = state.masterVolume
		this.state.masterVolume = state.masterVolume
	}

	setState = (state: AmplifierState) => {
		this.adsr.setState(state.adsr)
		this._setState(state)
	}

}
