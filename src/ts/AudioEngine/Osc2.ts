import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import PulseOscillatorFactory from './OscillatorNode/PulseOscillatorFactory'
import NoiseOscillatorFactory from './OscillatorNode/NoiseOscillatorFactory'
import BaseOscillator from './BaseOscillator'


export interface Osc2State {
	waveformType: string
	semitone: number
	detune: number
	kbdTrack: boolean
	pw: number
}

export class Osc2 extends BaseOscillator {

	private state = {} as Osc2State
	public widthGains = [] as Array<GainNode>

	constructor(context: AudioContext) {
		super(context)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.widthGains[i] = this.context.createGain()
		}
	}

	private kill = (midiNote: number) => {
		this.vcos[midiNote].disconnect()
	}

	public noteOn = (midiNote: number) => {
		const now = this.context.currentTime
		let vco = this.vcos[midiNote]

		if (vco !== null) {
			vco.stop(now)
			this.vcos[midiNote].disconnect()
		}

		if (this.state.waveformType === CONSTANTS.WAVEFORM_TYPE.PULSE) {
			vco = PulseOscillatorFactory
				.createPulseOscillator(this.context, this.widthGains[midiNote])
		} else if (this.state.waveformType === CONSTANTS.WAVEFORM_TYPE.NOISE) {
			vco = NoiseOscillatorFactory
				.createNoiseOscillator(this.context)
		} else {
			vco = this.context.createOscillator()
			vco.type = this.state.waveformType
		}

		vco.frequency.value = MIDI.toFrequency(this.state.kbdTrack
			? midiNote
			: 60
		)

		vco.detune.value = this.state.detune + this.state.semitone
		vco.onended = () => this.kill(midiNote)

		this.vcos[midiNote] = vco

		vco.connect(this.outputs[midiNote])
		vco.start(now)
	}

	public setWaveform = (waveform: string) => {
		if (CONSTANTS.OSC2_WAVEFORM_TYPES.indexOf(waveform) !== -1) {
			this.state.waveformType = waveform
			for (let voice = 0; voice < CONSTANTS.MAX_VOICES; voice++) {
				if (this.vcos[voice] !== null) {
					this.noteOn(voice)
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

	public setSemitone = (semitone: number) => {
		this.state.semitone = semitone * 100
		this.vcos.forEach(vco => {
			if (vco !== null) {
				vco.detune.value =
					this.state.detune + this.state.semitone
			}
		})
	}

	public setDetune = (detune: number) => {
		this.state.detune = detune
		this.vcos.forEach(vco => {
			if (vco !== null) {
				vco.detune.value =
					detune + this.state.semitone
			}
		})
	}

	public setState = (state: Osc2State) => {
		this.setWaveform(state.waveformType)
		this.setPulseWidth(state.pw)
		this.setDetune(state.detune)
		this.toggleKbdTrack(state.kbdTrack)
		this.setSemitone(state.semitone)
	}
}
