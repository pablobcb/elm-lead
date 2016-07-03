
import Oscillators from './Oscillators'
import Filter from './Filter'
import Amplifier from './Amplifier'
import Overdrive from './Overdrive'

import CONSTANTS from '../Constants'

export default class Synth {
	constructor(preset) {
		this.context = new AudioContext

		this.state = preset

		this.amplifier = new Amplifier(this.context, this.state.amp)

		this.overdrive = new Overdrive(this.context, CONSTANTS.OVERDRIVE_PARAMS)
		this.overdrive.connect(this.amplifier.output)

		this.filter = new Filter(this.context, this.state.filter)
		this.filter.connect(this.overdrive.input)

		this.oscillators = new Oscillators(this.context, this.state.oscs)
		this.oscillators.connect(this.filter.node)
	}

	_ = () => { }

	onMIDIMessage = data => {
		//console.log(data)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf
		// channel agnostic message type
		const type = data[0] & 0xf0
		const note = data[1]
		//const velocity = data[2]

		switch (type) {
			case CONSTANTS.MIDI_EVENT.NOTE_ON:
				this.oscillators.noteOn(note,
					this.amplifier.adsr.on)
				break
			case CONSTANTS.MIDI_EVENT.NOTE_OFF:
				this.oscillators.noteOff(note,
					this.amplifier.adsr.off)
				break
		}
	}
}