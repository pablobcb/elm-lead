
import Oscillators from './Oscillators'
import {Filter} from './Filter'
import {Amplifier} from './Amplifier'
import {Overdrive} from './Overdrive'
import CONSTANTS from '../Constants'


export default class Synth {

	public context : AudioContext
	public amplifier : Amplifier
	public overdrive : Overdrive
	public filter : Filter
	public oscillators : Oscillators

	constructor(state: any) {
		this.context = new AudioContext

		this.amplifier = new Amplifier(this.context, state.amp)

		this.overdrive = new Overdrive(this.context)
		this.overdrive.setState(state.overdrive)
		this.overdrive.connect(this.amplifier.output)

		this.filter = new Filter(this.context)
		this.filter.setState(state.filter)
		this.filter.connect(this.overdrive.input)

		this.oscillators = new Oscillators(this.context)
		this.oscillators.setState(state.oscs)
		this.oscillators.connect(this.filter.input)
	}

	setState = (state: any) => {
		this.amplifier.setState(state.amp)
		this.overdrive.setState(state.overdrive)
		this.filter.setState(state.filter)
		this.oscillators.setState(state.oscs)
	}

	onMIDIMessage = (data: any) => {
		//console.log(data)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf
		// channel agnostic message type
		const type = data[0] & 0xf0
		const note = data[1]
		//const velocity = data[2]

		switch (type) {
			case CONSTANTS.MIDI_EVENT.NOTE_ON:
				this.oscillators.noteOn(note, this.amplifier.adsr.on(0, 1))
				this.filter.noteOn()
				break
			case CONSTANTS.MIDI_EVENT.NOTE_OFF:
				this.oscillators.noteOff(note, this.amplifier.adsr.off)
				this.filter.noteOff()
				break
		}
	}
}
