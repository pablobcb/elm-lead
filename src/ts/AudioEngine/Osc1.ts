import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import BaseOscillator from './BaseOscillator'


export interface Osc1State {
	waveformType: string
	fmAmount: number
}
export class Osc1 extends BaseOscillator {

	public state = {} as Osc1State
	//public fmInputs = [] as Array<GainNode>
	public fmInputs = [] as Array<any>

	constructor(context: AudioContext) {
		super(context)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.fmInputs[i] = context.createGain()
		}
	}

	private kill = (midiNote: number) => {
		this.fmInputs[midiNote].disconnect()
		this.vcos[midiNote].disconnect()
	}

	public noteOn = (midiNote: number) => {
		const now = this.context.currentTime
		let vco = this.vcos[midiNote]

		if (vco !== null) {
			vco.stop(now)
			this.kill(midiNote)
		}

		vco = this.context.createOscillator()
		vco.type = this.state.waveformType
		vco.frequency.value = MIDI.toFrequency(midiNote)
		vco.connect(this.outputs[midiNote])
		this.fmInputs[midiNote].connect(vco.frequency)

		this.vcos[midiNote] = vco

		vco.onended = () => this.kill(midiNote)

		vco.start(now)
	}

	public setWaveform = (waveform: string) => {
		if (CONSTANTS.OSC1_WAVEFORM_TYPES.indexOf(waveform) !== -1) {
			this.state.waveformType = waveform
			for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
				if (this.vcos[i] !== null) {
					this.vcos[i].type = waveform
				}
			}
		} else {
			throw new Error(`Invalid Waveform Type ${waveform}`)
		}
	}

	public setFmAmount = (fmAmount: number) => {
		MIDI.validateValue(fmAmount)
		const amount = 10 * MIDI.logScaleToMax(fmAmount, 100)
		this.state.fmAmount = amount

		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.fmInputs[i].gain.value = amount
		}
	}

	public setState = (state: Osc1State) => {
		this.setFmAmount(state.fmAmount)
		this.setWaveform(state.waveformType)
	}
}
