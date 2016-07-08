import MIDI from '../MIDI'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import { BaseOscillator } from './Oscillator/BaseOscillator'


const midiToFreq = (midiValue: number): number =>
	440 * Math.pow(2, (midiValue - 69) / 12)


export default class Osc1 {

	private context: AudioContext
	private waveform: string
	private vcos = [] as Array<OscillatorNode>
	public outputs = [] as Array<GainNode>
	public fmInputs = [] as Array<GainNode>


	constructor(context: AudioContext) {
		this.context = context
		this.waveform = 'sawtooth'
		for (let i = 0; i < 128; i++) {
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

		vco.type = this.waveform
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
		for (let i = 0; i < 128; i++) {
			if (this.vcos[i] !== null) {
				this.vcos[i].stop()
			}
		}
	}

	public connect(node: AudioParam) {
		for (let i = 0; i < 128; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].connect(node)
			}
		}
	}

	public disconnect(node: AudioParam) {
		for (let i = 0; i < 128; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].disconnect(node)
			}
		}
	}

	public setWaveform(waveform: string) {
		for (let i = 0; i < 128; i++) {
			if (this.vcos[i] !== null) {
				this.vcos[i].type = waveform
			}
		}
	}

	public setFmAmount = (fmGain: number) => {
		for (let i = 0; i < 128; i++) {
			this.fmInputs[i].gain.value = fmGain
		}
	}
}
