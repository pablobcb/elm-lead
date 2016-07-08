import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import { BaseOscillator } from './Oscillator/BaseOscillator'

type WaveformType = string

interface Oscillator1State {
	waveformType: WaveformType
	fmGain: number
}

interface Oscillator2State {
	waveformType: WaveformType
	semitone: number
	detune: number
	kbdTrack: boolean
}

export interface OscillatorsState {
	mix: number
	pw: number
	osc1: Oscillator1State
	osc2: Oscillator2State
}

// TODO: move set state to Oscillator.js
export default class Oscillators {

	public context: AudioContext
	public state: any
	public oscillator1Gain: GainNode
	public oscillator1: FMOscillator
	public oscillator2Gain: GainNode
	public oscillator2: BaseOscillator
	public fmGains: Array<GainNode>

	constructor (context: AudioContext, state: OscillatorsState) {
		this.context = context
		this.state = state

/***************************/
/* AudioNode graph routing */
/***************************/
		/* create oscillators gains */
		this.oscillator1Gain = this.context.createGain()
		this.oscillator2Gain = this.context.createGain()

		/* create oscillator nodes */
		this.oscillator1 =
			new FMOscillator(this.context, state.osc1.waveformType)

		this.oscillator2 = this._newOscillator(state.osc2.waveformType)

		/* connect oscs with the previously mixed gains */
		this.oscillator1.connect(this.oscillator1Gain)
		this.oscillator2.connect(this.oscillator2Gain)

		/* create Frequency Modulation gains */
		this.fmGains = []
		for (let i = 0; i < 128; i++) {
			this.fmGains[i] = this.context.createGain()
			this.fmGains[i].gain.value = state.osc1.fmGain

			this.oscillator2.voiceGains[i].connect(this.fmGains[i])
			this.fmGains[i].connect(this.oscillator1.frequencyGains[i])
		}

		this._setState(state)
	}

/***************************/
/*     private methods     */
/***************************/

	_setState = (state: OscillatorsState) => {
		this._setMix(state.mix)
		this.setFmAmount(state.osc1.fmGain)

		this._setPulseWidth(state.pw)
		this.setOscillator2Semitone(state.osc2.semitone)
		this.setOscillator2Detune(state.osc2.detune)
		this.toggleOsc2KbdTrack(state.osc2.kbdTrack)
	}

	_setMix = (mix: number) => {
		/* calculate and set volume mix between oscillators */
		this.state.mix = mix

		const osc1GainValue = (1 - this.state.mix) / 2
		this.oscillator1Gain.gain.value = osc1GainValue

		const osc2GainValue = .5 - osc1GainValue
		this.oscillator2Gain.gain.value = osc2GainValue
	}

	_setPulseWidth = (pw: number) => {
		this.state.pw = pw
		this.oscillator2.setPulseWidth(pw)
	}

	_newOscillator = (waveformType: WaveformType): BaseOscillator => {
		if (waveformType == CONSTANTS.WAVEFORM_TYPE.PULSE) {
			return new PulseOscillator(this.context)
		} else if (waveformType == CONSTANTS.WAVEFORM_TYPE.NOISE) {
			return new NoiseOscillator(this.context)
		} else {
			return new FMOscillator(this.context, waveformType)
		}
	}

	_setOscillator2Waveform = (waveform: WaveformType) => {
		if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
			&& waveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {

			if (waveform === CONSTANTS.WAVEFORM_TYPE.PULSE) {
				this._swapOsc2(new PulseOscillator(this.context),
					this.oscillator2Gain)
			} else {
				this.oscillator2.setWaveform(waveform)
			}
		} else if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
			&& waveform === CONSTANTS.WAVEFORM_TYPE.NOISE) {

			this._swapOsc2(new NoiseOscillator(this.context),
				this.oscillator2Gain)
		} else if (this.oscillator2.type === CONSTANTS.WAVEFORM_TYPE.NOISE
			&& waveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {
			this._swapOsc2(
				new FMOscillator(this.context, waveform),
				this.oscillator2Gain
			)
		}
		this.state.osc2.waveformType = waveform
	}

	_swapOsc2 = (osc: any, gainB: any) => {
		const now = this.context.currentTime
		for (let midiNote in this.oscillator2.voices) {
			if (this.oscillator2.voices.hasOwnProperty(midiNote)) {
				this.oscillator2.noteOff(now, midiNote)
				osc.noteOn(midiNote)
			}
		}
		this.oscillator2.voiceGains.forEach((oscGain: GainNode, i: number) =>
			// oscGain.disconnect(this.fmGains[i])
			oscGain.disconnect()
		)
		this.oscillator2.disconnect(gainB)

		this.oscillator2 = osc
		this.oscillator2.setPulseWidth(this.state.pw)
		this.oscillator2.setDetune(this.state.osc2.detune)
		this.oscillator2.setKbdTrack(this.state.osc2.kbdTrack)
		this.oscillator2.setSemitone(this.state.osc2.semitone)

		this.oscillator2.voiceGains.forEach((oscGain: GainNode, i: number) =>
			oscGain.connect(this.fmGains[i])
		)
		this.oscillator2.connect(gainB)
	}

	setState = (state: OscillatorsState) => {
		this._setState(state)
		this.oscillator1.setWaveform(state.osc1.waveformType)
		this._setOscillator2Waveform(state.osc2.waveformType)
	}

	setMix = (mix: number) => {
		this._setMix(MIDI.normalizeValue(mix))
	}

	setOscillator2Semitone = (oscillatorSemitone: number) => {
		this.state.osc2.semitone = oscillatorSemitone
		this.oscillator2.setSemitone(oscillatorSemitone)
	}

	setOscillator2Detune = (oscillatorDetune: number) => {
		this.state.osc2.detune = oscillatorDetune
		this.oscillator2.setDetune(oscillatorDetune)
	}

	setFmAmount = (fmAmount: number) => {
		const amount =
			20 * MIDI.logScaleToMax(fmAmount , 100)
			//10 * fmAmount

		this.state.osc1.fmGain = amount
		console.log(fmAmount, amount)
		for (let i = 0; i < CONSTANTS.MAX_NOTES; i++) {
			this.fmGains[i].gain.value = amount
		}
	}

	setPulseWidth = (midiValue: number) => {
		this._setPulseWidth(MIDI.logScaleToMax(midiValue, .9))
	}


	setOscillator1Waveform = (waveform: WaveformType) => {
		const wf = waveform.toLowerCase()
		if (CONSTANTS.OSC1_WAVEFORM_TYPES.indexOf(wf) !== -1) {
			this.oscillator1.setWaveform(wf)
		} else {
			throw new Error(`Invalid Waveform Type ${wf}`)
		}
	}

	toggleOsc2KbdTrack = (enabled: boolean) => {
		this.state.osc2.kbdTrack = enabled
		this.oscillator2.setKbdTrack(enabled)
	}


	setOscillator2Waveform =  (waveform: WaveformType) => {
		const wf = waveform.toLowerCase()
		if (CONSTANTS.OSC2_WAVEFORM_TYPES.indexOf(wf)) {
			this._setOscillator2Waveform(wf)
		} else {
			throw new Error(`Invalid Waveform Type ${wf}`)
		}
	}

	connect = (node: any) => {
		this.oscillator2Gain.connect(node)
		this.oscillator1Gain.connect(node)
	}

	disconnect = (node: any) => {
		this.oscillator2Gain.disconnect(node)
		this.oscillator1Gain.disconnect(node)
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
