import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import { BaseOscillator } from './Oscillator/BaseOscillator'


const midiToFreq = (midiValue: number): number =>
	440 * Math.pow(2, (midiValue - 69) / 12)

interface Osc1State {
	waveformType: string
	fmAmount: number
}
export default class Osc1 {

	private state = {} as Osc1State
	private context: AudioContext
	private vcos = [] as Array<OscillatorNode>
	public outputs = [] as Array<GainNode>
	public fmInputs = [] as Array<GainNode>


	constructor(context: AudioContext) {
		this.context = context
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.fmInputs[i] = context.createGain()
			this.outputs[i] = context.createGain()
			this.vcos[i] = null
		}
	}


	private kill = (midiNote: number) => {
		this.fmInputs[midiNote].disconnect()
		this.vcos[midiNote].disconnect(this.outputs[midiNote])
		this.vcos[midiNote] = null
	}

	public noteOn = (midiNote: number, noteOnAmpCB: any) => {
		const now = this.context.currentTime
		let vco = this.vcos[midiNote]

		if (vco !== null) {
			vco.stop(now)
			this.kill(midiNote)
		}

		vco = this.context.createOscillator()

		vco.type = this.state.waveformType
		vco.frequency.value = midiToFreq(midiNote)
		vco.connect(this.outputs[midiNote])
		this.fmInputs[midiNote].connect(vco.frequency)

		this.vcos[midiNote] = vco

		vco.onended = () => this.kill(midiNote)

		vco.start(now)

		if (noteOnAmpCB) {
			noteOnAmpCB(this.outputs[midiNote].gain)
		}
	}

	public noteOff = (midiNote: number, noteOffAmpCB: any) => {
		const midiNoteKey = midiNote.toString()
		const vco = this.vcos[midiNote]
		if (!vco) {
			return
		}
		const releaseTime = noteOffAmpCB(this.outputs[midiNote].gain)
		vco.stop(releaseTime)
	}

	public panic = () => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.vcos[i] !== null) {
				this.vcos[i].stop()
			}
		}
	}

	public connect(node: AudioParam) {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].connect(node)
			}
		}
	}

	public disconnect(node: AudioParam) {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].disconnect(node)
			}
		}
	}

	public setWaveform(waveform: string) {
		const wf = waveform.toLowerCase()
		if (CONSTANTS.OSC1_WAVEFORM_TYPES.indexOf(wf) !== -1) {
			this.state.waveformType = waveform
			for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
				if (this.vcos[i] !== null) {
					this.vcos[i].type = waveform
				}
			}
		} else {
			throw new Error(`Invalid Waveform Type ${wf}`)
		}
	}

	public setFmAmount = (fmAmount: number) => {
		const amount = 10 * MIDI.logScaleToMax(fmAmount, 100)
		this.state.fmAmount = amount

		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.fmInputs[i].gain.value = amount
		}
	}

	public setState(state: Osc1State) {
		this.setFmAmount(state.fmAmount)
		this.setWaveform(state.waveformType)
	}
}
