import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import Osc1 from './Osc1'
import Osc2 from './Osc2'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import { BaseOscillator } from './Oscillator/BaseOscillator'
import DualMixer from './DualMixer'

type WaveformType = string



interface Oscillator2State {
	waveformType: WaveformType
	semitone: number
	detune: number
	kbdTrack: boolean
}

export interface OscillatorsState {
	mix: number
	pw: number
	osc1: any
	osc2: Oscillator2State
}

// TODO: move set state to Oscillator.js
export default class Oscillators {

	public context: AudioContext
	public state: OscillatorsState = {
		osc1: {}, osc2: {}
	} as OscillatorsState

	public oscillator1: Osc1
	public oscillator2: Osc2

	public mixer:DualMixer

	constructor (context: AudioContext) {
		this.context = context

		/* AudioNode graph routing */

		this.mixer = new DualMixer(context)

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
		this.mixer.setState(state.mix)
		this.oscillator2.setPulseWidth(state.pw)
		this.oscillator2.setSemitone(state.osc2.semitone)
		this.oscillator2.setDetune(state.osc2.detune)
		this.oscillator2.toggleOsc2KbdTrack(state.osc2.kbdTrack)
		this.oscillator2.setWaveform(state.osc2.waveformType)
	}


	//_newOscillator = (waveformType: WaveformType): BaseOscillator => {
	//	if (waveformType == CONSTANTS.WAVEFORM_TYPE.PULSE) {
	//		return new PulseOscillator(this.context)
	//	} else if (waveformType == CONSTANTS.WAVEFORM_TYPE.NOISE) {
	//		return new NoiseOscillator(this.context)
	//	} else {
	//		return new FMOscillator(this.context, waveformType)
	//	}
	//}

//	_setOscillator2Waveform = (waveform: WaveformType) => {
//		if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
//			&& waveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {
//
//			if (waveform === CONSTANTS.WAVEFORM_TYPE.PULSE) {
//				this._swapOsc2(new PulseOscillator(this.context),
//					this.mixer.channel2)
//			} else {
//				this.oscillator2.setWaveform(waveform)
//			}
//		} else if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
//			&& waveform === CONSTANTS.WAVEFORM_TYPE.NOISE) {
//
//			this._swapOsc2(new NoiseOscillator(this.context),
//				this.mixer.channel2)
//		} else if (this.oscillator2.type === CONSTANTS.WAVEFORM_TYPE.NOISE
//			&& waveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {
//			this._swapOsc2(
//				new FMOscillator(this.context, waveform),
//				this.mixer.channel2
//			)
//		}
//		this.state.osc2.waveformType = waveform
//	}

//	_swapOsc2 = (osc: any, gainB: any) => {
//		const now = this.context.currentTime
//		for (let midiNote in this.oscillator2.voices) {
//			if (this.oscillator2.voices.hasOwnProperty(midiNote)) {
//				this.oscillator2.noteOff(now, midiNote)
//				osc.noteOn(midiNote)
//			}
//		}
//		this.oscillator2.voiceGains.forEach((oscGain: GainNode, i: number) =>
//			// oscGain.disconnect(this.fmGains[i])
//			oscGain.disconnect()
//		)
//		this.oscillator2.disconnect(gainB)
//
//		this.oscillator2 = osc
//		this.oscillator2.setPulseWidth(this.state.pw)
//		this.oscillator2.setDetune(this.state.osc2.detune)
//		this.oscillator2.setKbdTrack(this.state.osc2.kbdTrack)
//		this.oscillator2.setSemitone(this.state.osc2.semitone)
//
//		this.oscillator2.voiceGains.forEach((oscGain: GainNode, i: number) =>
//			oscGain.connect(this.fmAmount[i])
//		)
//		this.oscillator2.connect(gainB)
//	}


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
