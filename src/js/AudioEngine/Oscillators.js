import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'


export default class Oscillators {
	constructor (context, state) {
		this.context = context
		this.state = state

		this.oscillator1Gain = this.context.createGain()
		const osc1GainValue = (1 - state.mix) / 2
		this.oscillator1Gain.gain.value = osc1GainValue

		this.oscillator1 = new FMOscillator(this.context,
			state.osc1.waveformType)
		this.oscillator1.connect(this.oscillator1Gain)

		this.oscillator2Gain = this.context.createGain()
		const osc2GainValue = Math.abs(osc1GainValue - .5)
		this.oscillator2Gain.gain.value = osc2GainValue

		if(state.osc2.waveformType == CONSTANTS.WAVEFORM_TYPE.PULSE) {
			this.oscillator2 = new PulseOscillator((this.context),
				this.oscillator2Gain)
		}
		if(state.osc2.waveformType == CONSTANTS.WAVEFORM_TYPE.NOISE) {
			this.oscillator2 = new NoiseOscillator((this.context),
				this.oscillator2Gain)
		}
		else{
			this.oscillator2 = new FMOscillator(this.context,
				state.osc2.waveformType)
		}
		
		this.oscillator2.connect(this.oscillator2Gain)

		//TODO : IMPLEMENT OSC CLASS WHICH HOLDS FMGAIN
		this.fmGains = []
		for (let i = 0; i < 128; i++) {
			this.fmGains[i] = this.context.createGain()
			this.fmGains[i].gain.value = state.osc1.fmGain

			this.oscillator2.voiceGains[i].connect(this.fmGains[i])
			this.fmGains[i].connect(this.oscillator1.frequencyGains[i])
		}
	}

	_ = () => {}


	setMix = mix => {
		this.state.mix = MIDI.normalizeValue(mix)

		const osc1GainValue = (1 - this.state.mix) / 2
		this.oscillator1Gain.gain.value = osc1GainValue

		const osc2GainValue = .5 - osc1GainValue
		this.oscillator2Gain.gain.value = osc2GainValue
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
		const pw = MIDI.logScaleToMax(midiValue, .9)

		this.state.pw = pw
		this.oscillator2.setPulseWidth(pw)
	}

	setOscillator1Waveform = waveform => {
		if (CONSTANTS.OSC1_WAVEFORM_TYPES.includes(waveform.toLowerCase())) {
			this.oscillator1.setWaveform(waveform.toLowerCase())
		}
		else {
			throw new Error(`Invalid Waveform Type ${waveform.toLowerCase()}`)
		}		
	}

	toggleOsc2KbdTrack = isActive => {
		this.state.osc2.kbdTrack = isActive
		this.oscillator2.setKbdTrack(isActive)
	}

	setOscillator2Waveform = waveform => {

		const nextWaveform = waveform.toLowerCase()

		if (! CONSTANTS.OSC2_WAVEFORM_TYPES.includes(nextWaveform)) {
			throw new Error(`Invalid Waveform Type ${nextWaveform}`)
		}

		if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
			&& nextWaveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {

			if (nextWaveform === CONSTANTS.WAVEFORM_TYPE.PULSE) {
				this.swapOsc2(new PulseOscillator(this.context),
					this.oscillator2Gain)
			}
			else {
				this.oscillator2.setWaveform(nextWaveform)
			}
		}
		else if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
			&& nextWaveform === CONSTANTS.WAVEFORM_TYPE.NOISE) {

			this.swapOsc2(new NoiseOscillator(this.context),
				this.oscillator2Gain)
		}
		else if (this.oscillator2.type === CONSTANTS.WAVEFORM_TYPE.NOISE
			&& nextWaveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {
			this.swapOsc2(
				new FMOscillator(this.context, nextWaveform),
				this.oscillator2Gain
			)
		}
		this.state.osc2.waveformType = nextWaveform
	}

	swapOsc2 = (osc, gainB) => {
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

	connect = node => {
		this.oscillator2Gain.connect(node)
		this.oscillator1Gain.connect(node)
	}

	disconnect = node => {
		this.oscillator2Gain.disconnect(node)
		this.oscillator1Gain.disconnect(node)
	}

	panic = () => {
		this.oscillator1.panic()
		this.oscillator2.panic()
	}

	noteOn = (midiNote, noteOnCb /*, velocity*/) => {
		this.oscillator1.noteOn(midiNote, noteOnCb)
		this.oscillator2.noteOn(midiNote, noteOnCb)
		//this.state.filter.amp.on(this.filter.frequency,
		//	this.filter.frequency.value)

	}

	noteOff = (midiNote, noteOffCb /*, velocity*/) => {
		this.oscillator1.noteOff(midiNote, noteOffCb)
		this.oscillator2.noteOff(midiNote, noteOffCb)
		//this.state.filter.off(this.filter.frequency)
	}
}