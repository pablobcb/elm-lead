import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import BaseOscillator from './Oscillator/BaseOscillator'

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

interface OscillatorState {
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

	constructor (context: AudioContext, state: OscillatorState) {
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

	_setState = (state: OscillatorState) => {
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

	_setPulseWidth = (pw: any) => {
		this.state.pw = pw
		this.oscillator2.setPulseWidth(pw)
	}

	_newOscillator = (waveformType: WaveformType) => {
		let newOsc : 
		if (waveformType == CONSTANTS.WAVEFORM_TYPE.PULSE) {
			newOsc = new PulseOscillator(this.context)
		}
		if (waveformType == CONSTANTS.WAVEFORM_TYPE.NOISE) {
			newOsc = new NoiseOscillator(this.context)
		}
		else {
			newOsc = new FMOscillator(this.context, waveformType)
		}
		return newOsc
	}

	_setOscillator2Waveform = waveform => {
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
		for (const midiNote in this.oscillator2.voices) {
			if (this.oscillator2.voices.hasOwnProperty(midiNote)) {
				this.oscillator2.noteOff(now, midiNote)
				osc.noteOn(midiNote)
			}
		}
		this.oscillator2.voiceGains.forEach((oscGain, i) =>
			oscGain.disconnect(this.fmGains[i])
		)
		this.oscillator2.disconnect(gainB)

		this.oscillator2 = osc
		this.oscillator2.setPulseWidth(this.state.pw)
		this.oscillator2.setDetune(this.state.osc2.detune)
		this.oscillator2.setKbdTrack(this.state.osc2.kbdTrack)
		this.oscillator2.setSemitone(this.state.osc2.semitone)

		this.oscillator2.voiceGains.forEach((oscGain, i) =>
			oscGain.connect(this.fmGains[i])
		)
		this.oscillator2.connect(gainB)
	}

/***************************/
/*     public  methods     */
/***************************/
	setState = state => {
		this._setState(state)
		this.oscillator1.setWaveform(state.osc1.waveformType)
		this._setOscillator2Waveform(state.osc2.waveformType)
	}

	setMix = mix => {
		this._setMix(MIDI.normalizeValue(mix))
	}

	setOscillator2Semitone = oscillatorSemitone => {
		this.state.osc2.semitone = oscillatorSemitone
		this.oscillator2.setSemitone(oscillatorSemitone)
	}

	setOscillator2Detune = oscillatorDetune => {
		this.state.osc2.detune = oscillatorDetune
		this.oscillator2.setDetune(oscillatorDetune)
	}

	setFmAmount = fmAmount => {
		const amount = 10 * fmAmount

		this.state.osc1.fmGain = amount
		for (let i = 0; i < CONSTANTS.MAX_NOTES; i++) {
			this.fmGains[i].gain.value = amount
		}
	}

	setPulseWidth = midiValue => {
		this._setPulseWidth(MIDI.logScaleToMax(midiValue, .9))
	}


	setOscillator1Waveform = waveform => {
		if (CONSTANTS.OSC1_WAVEFORM_TYPES.includes(waveform.toLowerCase())) {
			this.oscillator1.setWaveform(waveform.toLowerCase())
		} else {
			throw new Error(`Invalid Waveform Type ${waveform.toLowerCase()}`)
		}
	}

	toggleOsc2KbdTrack = isActive => {
		this.state.osc2.kbdTrack = isActive
		this.oscillator2.setKbdTrack(isActive)
	}


	setOscillator2Waveform = waveform => {
		if (CONSTANTS.OSC2_WAVEFORM_TYPES.includes(waveform.toLowerCase())) {
			this._setOscillator2Waveform(waveform.toLowerCase())
		} else {
			throw new Error(`Invalid Waveform Type ${waveform}`)
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

	noteOn = (midiNote: any, noteOnCb: any /*, velocity*/) => {
		this.oscillator1.noteOn(midiNote, noteOnCb)
		this.oscillator2.noteOn(midiNote, noteOnCb)
	}

	noteOff = (midiNote: any, noteOffCb: any /*, velocity*/) => {
		this.oscillator1.noteOff(midiNote, noteOffCb)
		this.oscillator2.noteOff(midiNote, noteOffCb)
	}
}
