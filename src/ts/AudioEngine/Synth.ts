
import {Osc1, Osc1State} from './Osc1'
import {Osc2, Osc2State} from './Osc2'
import {Filter, FilterState} from './Filter'
import {Amplifier, AmplifierState} from './Amplifier'
import {Overdrive} from './Overdrive'
import VCA from './VCA'
import CONSTANTS from '../Constants'
import DualMixer from './DualMixer'

interface SynthState {
	overdrive: boolean
	filter: FilterState
	amp: AmplifierState
	oscs: {
		mix: number
		osc1: Osc1State
		osc2: Osc2State
	}
}

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

		this.oscillator1 = new Osc1(this.context)
		this.oscillator2 = new Osc2(this.context)

		/* connect oscs with the previously mixed gains */
		this.oscillator1.connect(this.mixer.channel1)
		this.oscillator2.connect(this.mixer.channel2)

		this.vca = new VCA(this.context)
		this.mixer.connect(this.vca.inputs)
		this.vca.connect(this.filter.input)
	}

	setState = (state: SynthState) => {
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
				this.oscillator1.noteOn(note)
				this.oscillator2.noteOn(note)
				this.amplifier.adsr.on(0, 1)(this.vca.inputs[note].gain)
				this.filter.noteOn()
				break
			case CONSTANTS.MIDI_EVENT.NOTE_OFF:
				const releaseTime =
					this.amplifier.adsr.off(this.vca.inputs[note].gain)
				this.oscillator1.noteOff(note, releaseTime)
				this.oscillator2.noteOff(note, releaseTime)
				this.filter.noteOff()
				break
		}
	}
}
