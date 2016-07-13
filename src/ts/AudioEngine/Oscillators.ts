import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import Osc1 from './Osc1'
import Osc2 from './Osc2'
import { BaseOscillator } from './Oscillator/BaseOscillator'
import DualMixer from './DualMixer'


// TODO: move set state to Oscillator.js
export default class Oscillators {

	public context: AudioContext
	public state: OscillatorsState = {
		osc1: {}, osc2: {}
	} as OscillatorsState

	public oscillator1: Osc1
	public oscillator2: Osc2


	constructor (context: AudioContext) {
		this.context = context

		/* AudioNode graph routing */


		/* create oscillator nodes */
		this.oscillator1 =
			new Osc1(context)

		this.oscillator2 =
			new Osc2(context)

		/* connect oscs with the previously mixed gains */
		this.oscillator1.connect(this.mixer.channel1)
		this.oscillator2.connect(this.mixer.channel2)

		/* connect Osc2 to Osc1 FM Input */
		/* Osc1 is the Carrier and Osc 2 the Modulator */
		this.oscillator1.connectToFm(this.oscillator2.outputs)
	}

	public setState = (state: OscillatorsState) => {
		this.oscillator1.setState(state.osc1)
		this.oscillator2.setState(state.osc2)
		this.mixer.setState(state.mix)
	}


	connect = (node: any) => {
		this.mixer.channel1.connect(node)
		this.mixer.channel2.connect(node)
	}

	disconnect = (node: any) => {
		this.mixer.channel1.disconnect(node)
		this.mixer.channel2.disconnect(node)
	}

	panic = () => {
		this.oscillator1.panic()
		this.oscillator2.panic()
	}

	noteOn = (midiNote: number, noteOnCb: any /*, velocity*/) => {
		this.oscillator1.noteOn(midiNote, noteOnCb)
		this.oscillator2.noteOn(midiNote, noteOnCb)
	}

	noteOff = (midiNote: number, noteOffCb: any /*, velocity*/) => {
		this.oscillator1.noteOff(midiNote, noteOffCb)
		this.oscillator2.noteOff(midiNote, noteOffCb)
	}
}
