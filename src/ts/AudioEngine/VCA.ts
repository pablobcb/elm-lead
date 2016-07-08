import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import { BaseOscillator } from './Oscillator/BaseOscillator'

export default class VCA {

	public context: AudioContext

	public input: Array<GainNode>

	constructor (context: AudioContext) {
		this.context = context
		for (let i = 0; i < 128; i++) {
			this.input[i] = context.createGain()
		}
	}
	// TODO:
	// linear & exponential controls switch
	// mod input
	// mod amount knob/gain
}
