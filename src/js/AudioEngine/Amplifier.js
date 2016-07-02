import ADSR from './ADSR'
import MIDI from '../MIDI'

export default class Amplifier {
	constructor (context, state) {
		this.state = state
		this.context = context

		this.adsr = new ADSR(this.context, state)

		this.output = this.context.createGain()
		this.output.gain.value = this.state.masterVolume
		this.output.connect(this.context.destination)
	}

	_ = () => {}

	setMasterVolumeGain = midiValue => {
		const vol = MIDI.logScaleToMax(midiValue, 1)
		this.state.masterVolume = vol
		this.output.gain.value = vol
	}

	
}