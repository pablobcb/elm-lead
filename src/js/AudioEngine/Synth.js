import ADSR from './ADSR'
import Oscillators from './Oscillators'
import Filter from './Filter'
import MIDI from '../MIDI'
import CONSTANTS from '../Constants'

export default class Synth {
	constructor (preset) {
		this.context = new AudioContext

		this.state = preset

		this.ampADSR = new ADSR(this.context, 1)
		this.masterVolume = this.context.createGain()
		this.masterVolume.gain.value = this.state.masterVolume
		this.masterVolume.connect(this.context.destination)

		this.filter = new Filter(this.context, this.state.filter)
		this.filter.connect(this.masterVolume)	

		this.oscillators = new Oscillators(this.context, this.state.oscs)
		this.oscillators.connect(this.filter.node)

	}

	_ = () => {}

	onMIDIMessage = data => {
		//console.log(data)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf
		// channel agnostic message type
		const type = data[0] & 0xf0
		const note = data[1]
		const velocity = data[2]

		switch (type) {
			case CONSTANTS.MIDI_EVENT.NOTE_ON:
				this.oscillators.noteOn(note, this.ampADSR.on(this.state.amp))
				break
			case CONSTANTS.MIDI_EVENT.NOTE_OFF:
				this.oscillators.noteOff(note, this.ampADSR.off)
				break
		}
	}	

	setMasterVolumeGain = midiValue => {
		const vol = MIDI.logScaleToMax(midiValue, 1)
		this.state.masterVolume = vol
		this.masterVolume.gain.value = vol
	}

	setAmpAttack = midiValue => {
		this.state.amp.attack = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setAmpDecay = midiValue => {
		this.state.amp.decay = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setAmpSustain = midiValue => {
		this.state.amp.sustain = MIDI.logScaleToMax(midiValue, 1)
	}

	setAmpRelease = midiValue => {
		this.state.amp.release = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}	
}