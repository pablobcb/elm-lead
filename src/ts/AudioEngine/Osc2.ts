import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import { BaseOscillator } from './Oscillator/BaseOscillator'


const midiToFreq = (midiValue: number): number =>
	440 * Math.pow(2, (midiValue - 69) / 12)

interface Osc2State {
	waveformType: string
	semitone: number
	detune: number
	kbdTrack: boolean
	pw: number
}

export default class Osc2 {

	private state = {} as Osc2State
	private vcos = [] as Array<any>
	private context: AudioContext
	public outputs = [] as Array<GainNode>

	/* pulse wave stuff */
	private widthGains = [] as Array<GainNode>
	private pulseShaper: WaveShaperNode

	constructor(context: AudioContext) {
		this.context = context
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.outputs[i] = context.createGain()
			this.vcos[i] = null
			this.widthGains[i] = this.context.createGain()
		}
	}

	private kill = (midiNote: number) => {
		this.vcos[midiNote].disconnect()
		this.vcos[midiNote] = null
	}

	public noteOn = (midiNote: number, noteOnAmpCB: any) => {
		const now = this.context.currentTime
		let vco = this.vcos[midiNote]

		if (vco !== null) {
			vco.stop(now)
			this.kill(midiNote)
		}

		if(this.state.waveformType === CONSTANTS.WAVEFORM_TYPE.PULSE){

		} else if (this.state.waveformType === CONSTANTS.WAVEFORM_TYPE.NOISE) {

		} else {
			vco = this.context.createOscillator()
			vco.type = this.state.waveformType
			vco.frequency.value = midiToFreq(midiNote)
			vco.connect(this.outputs[midiNote])
		}

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

	public connect = (node: AudioParam) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].connect(node)
			}
		}
	}

	public disconnect = (node: AudioParam) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].disconnect(node)
			}
		}
	}

	public setWaveform = (waveform: string) => {
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

	public toggleOsc2KbdTrack = (enabled: boolean) => {
		this.state.kbdTrack = enabled
	}

	public setPulseWidth = (pw_: number) => {
		const pw = MIDI.logScaleToMax(pw_, .9)
		this.state.pw = pw
		this.widthGains.forEach(widthGain => {
			widthGain.gain.value = pw
		})
	}

	public setState = (state: Osc2State) => {
		this.setWaveform(state.waveformType)
	}

	public setSemitone (semitone: number) {
		this.state.semitone = semitone * 100
		this.vcos.forEach(vco => {
			if (vco !== null){
				vco.detune.value =
					this.state.detune + this.state.semitone
			}
		})
	} // can setSetime call setDetune?

	public setDetune = (detune: number) => {
		this.state.detune = detune
		this.vcos.forEach(vco => {
			if (vco !== null){
				vco.detune.value =
					detune + this.state.semitone
			}
		})
	}
}
