import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import PulseOscillatorFactory from './Oscillator/PulseOscillatorFactory'
import NoiseOscillatorFactory from './Oscillator/NoiseOscillatorFactory'
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
	public widthGains = [] as Array<GainNode>
	public outputs = [] as Array<GainNode>

	constructor(context: AudioContext) {
		this.context = context
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.outputs[i] = context.createGain()
			this.vcos[i] = null
			this.widthGains[i] = this.context.createGain()
		}
	}

	private kill = (midiNote: number) => {
		this.vcos[midiNote].disconnect(this.outputs[midiNote])
	}

	public noteOn = (midiNote: number) => {
		const now = this.context.currentTime
		let vco = this.vcos[midiNote]

		if (vco !== null) {
			vco.stop(now)
			this.vcos[midiNote].disconnect()
		}

		if(this.state.waveformType === CONSTANTS.WAVEFORM_TYPE.PULSE){
			vco = PulseOscillatorFactory
				.createPulseOscillator(this.context, this.widthGains[midiNote])
		} else if (this.state.waveformType === CONSTANTS.WAVEFORM_TYPE.NOISE) {
			vco = NoiseOscillatorFactory
				.createNoiseOscillator(this.context)
		} else {
			vco = this.context.createOscillator()
			vco.type = this.state.waveformType
		}

		vco.frequency.value = midiToFreq(midiNote)
		vco.detune.value = this.state.detune + this.state.semitone
		vco.onended = () => this.kill(midiNote)

		this.vcos[midiNote] = vco

		vco.connect(this.outputs[midiNote])
		vco.start(now)
	}

	//TODO: type alias at to seconds
	public noteOff = (midiNote: number, releaseTime : number) => {
		const midiNoteKey = midiNote.toString()
		const vco = this.vcos[midiNote]
		if (!vco) {
			return
		}
		vco.stop(releaseTime)
	}

	public panic = () => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.vcos[i] !== null) {
				this.vcos[i].stop()
			}
		}
	}

	public connect = (nodes: Array<AudioParam>) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].connect(nodes[i])
			}
		}
	}

	public disconnect = (node: Array<AudioParam>) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			if (this.outputs[i] !== null) {
				this.outputs[i].disconnect(nodes[i])
			}
		}
	}

	public setWaveform = (waveform: string) => {
		if (CONSTANTS.OSC2_WAVEFORM_TYPES.indexOf(waveform) !== -1) {
			this.state.waveformType = waveform
			for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
				if (this.vcos[i] !== null) {
					this.noteOn(i, null)
				}
			}
		} else {
			throw new Error(`Invalid Waveform Type ${waveform}`)
		}
	}

	public toggleKbdTrack = (enabled: boolean) => {
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
		this.setPulseWidth(state.pw)
		this.setDetune(state.detune)
		this.toggleKbdTrack(state.kbdTrack)
		this.setSemitone(state.semitone)
	}

	public setSemitone = (semitone: number) => {
		this.state.semitone = semitone * 100
		this.vcos.forEach(vco => {
			if (vco !== null){
				vco.detune.value =
					this.state.detune + this.state.semitone
			}
		})
	}

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
