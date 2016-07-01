import ADSR from './ADSR'
import MIDI from '../MIDI'
import CONSTANTS from '../Constants'

export default class Amplifier {
	constructor (context, state) {
		this.state = state

		this.adsr = new ADSR(this.context, 1)
		this.adsr.attack = this.state.attack
		this.adsr.decay = this.state.decay
		this.adsr.sustain = this.state.sustain
		this.adsr.release = this.state.release

		this.output = this.context.createGain()
		this.output.gain.value = this.state.amp.masterVolume
		this.output.connect(this.context.destination)
	}

	_ = () => {}

	setMasterVolumeGain = midiValue => {
		const vol = MIDI.logScaleToMax(midiValue, 1)
		this.state.masterVolume = vol
		this.output.gain.value = vol
	}

	setAttack = midiValue => {		 
		this.adsr.attack = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setDecay = midiValue => {
		this.adsr.decay = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setSustain = midiValue => {
		this.adsr.sustain = MIDI.logScaleToMax(midiValue, 1)
	}

	setRelease = midiValue => {
		this.adsr.release = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}
}