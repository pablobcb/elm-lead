import ADSR from './ADSR'
import MIDI from '../MIDI'

export default class Amplifier {
	constructor(context, state) {
		this.context = context

		/* amp state */
		this.state = {}
		this.state.masterVolume = state.masterVolume

		/* adsr state */
		this.adsr = new ADSR(this.context, state.adsr)

		/* AudioNode graph routing */
		this.output = this.context.createGain()
		this.output.gain.value = this.state.masterVolume
		this.output.connect(this.context.destination)
	}

	setMasterVolumeGain = midiValue => {
		const vol = MIDI.logScaleToMax(midiValue, 1)
		this.state.masterVolume = vol
		this.output.gain.value = vol
	}
}