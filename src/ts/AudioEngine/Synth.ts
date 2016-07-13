
import Osc1 from './Osc1'
import Osc2 from './Osc2'
import {Filter} from './Filter'
import {Amplifier} from './Amplifier'
import {Overdrive} from './Overdrive'
import VCA from './VCA'
import CONSTANTS from '../Constants'
import DualMixer from './DualMixer'

export default class Synth {

	public context: AudioContext
	public amplifier: Amplifier
	public overdrive: Overdrive
	public filter: Filter
	public oscillator1: Osc1
	public oscillator2: Osc2
	public vca: VCA
	public mixer: DualMixer

	constructor() {
		this.context = new AudioContext

		this.amplifier = new Amplifier(this.context)

		this.overdrive = new Overdrive(this.context)
		this.overdrive.connect(this.amplifier.output)

		this.filter = new Filter(this.context)
		this.filter.connect(this.overdrive.input)

		this.mixer = new DualMixer(this.context)
		this.mixer.connect(this.filter.input)

		//this.vca = new VCA(this.context)
		this.oscillator1 = new Osc1(this.context)
		this.oscillator2 = new Osc2(this.context)

		/* connect oscs with the previously mixed gains */
		this.oscillator1.connect(this.mixer.channel1)
		this.oscillator2.connect(this.mixer.channel2)
	}

	setState = (state: any) => {
		this.amplifier.setState(state.amp)
		this.overdrive.setState(state.overdrive)
		this.filter.setState(state.filter)
		this.oscillator1.setState(state.oscs.osc1)
		this.oscillator2.setState(state.oscs.osc2)
		this.mixer.setState(state.oscs.mix)
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
				this.oscillator1.noteOn(note, this.amplifier.adsr.on(0, 1))
				this.oscillator2.noteOn(note, this.amplifier.adsr.on(0, 1))
				this.filter.noteOn()
				break
			case CONSTANTS.MIDI_EVENT.NOTE_OFF:
				this.oscillator1.noteOff(note, this.amplifier.adsr.off)
				this.oscillator2.noteOff(note, this.amplifier.adsr.off)
				this.filter.noteOff()
				break
		}
	}
}
