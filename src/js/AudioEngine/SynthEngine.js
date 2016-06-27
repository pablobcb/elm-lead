import Oscillator from './Oscillator/Oscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import ADSR from './ADSR'
import CONSTANTS from '../Constants'

export default class SynthEngine {
	constructor () {
		this.context = new AudioContext

		this.state = {
			filter: {
				frequency: 12000,
				type: CONSTANTS.FILTER_TYPE.LOWPASS,
				Q: 0
			},
			amp: new ADSR(this.context, 0, .5, 1, .2, .1),
			oscs: {
				osc1: {
					waveformType: CONSTANTS.WAVEFORM_TYPE.SINE,
					gain: .5,
					fmGain : 0
				},
				osc2: {
					waveformType: CONSTANTS.WAVEFORM_TYPE.TRIANGLE,
					gain: .5,
					semitone: 0,
					detune: 0,
					kbdTrack: true
				},
				pw: 0
			}
		}

		this.initializeMasterOutput()

		this.initializeFilter()

		this.initializeOscillators()

		this.initializeOscillatorsGain()

		this.initializeFMGain()
	}

	initializeMasterOutput = () => {
		this.masterVolume = this.context.createGain()

		this.masterVolume.gain.value = this.state.amp.level
		this.masterVolume.connect(this.context.destination)
	}

	initializeFilter = () => {
		this.filter = this.context.createBiquadFilter()
		this.filter.type = this.state.filter.type
		this.filter.frequency.value = this.state.filter.frequency
		this.filter.Q.value = this.state.filter.Q

		this.filter.connect(this.masterVolume)
	}

	initializeOscillators = () => {
		this.oscillator1 = new Oscillator(this.context,
			this.state.oscs.osc1.waveformType)

		this.oscillator2 = new Oscillator(this.context,
			this.state.oscs.osc2.waveformType)
	}


	initializeOscillatorsGain = () => {
		this.oscillator1Gain = this.context.createGain()
		this.oscillator1Gain.gain.value = this.state.oscs.osc1.gain
		this.oscillator1Gain.connect(this.filter)
		this.oscillator1.connect(this.oscillator1Gain)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = this.state.oscs.osc2.gain
		this.oscillator2Gain.connect(this.filter)
		this.oscillator2.connect(this.oscillator2Gain)
	}

	initializeFMGain = () => {
		this.fmGains = []

		for (let i = 0; i < 128; i++) {
			this.fmGains[i] = this.context.createGain()
			this.fmGains[i].gain.value = this.state.oscs.osc1.fmGain

			//TODO : MOVE FM GAIN TO OSC CLASS
			this.oscillator2.oscillatorGains[i].connect(this.fmGains[i])
			this.fmGains[i].connect(this.oscillator1.frequencyGains[i])
		}
	}

	onMIDIMessage = (data) => {
		//console.log(data)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf

		// channel agnostic message type
		const type = data[0] & 0xf0
		const note = data[1]
		const velocity = data[2]

		switch (type) {
			case CONSTANTS.MIDI_EVENTS.NOTE_ON:
				this.noteOn(note, velocity)
				break
			case CONSTANTS.MIDI_EVENTS.NOTE_OFF:
				this.noteOff(note, velocity)
				break
		}
	}

	noteOn = (midiNote /*, velocity*/) => {
		this.oscillator1.noteOn(midiNote)
		this.oscillator2.noteOn(midiNote)
	}

	noteOff = (midiNote /*, velocity*/) => {
		this.oscillator1.noteOff(this.context.currentTime, midiNote)
		this.oscillator2.noteOff(this.context.currentTime, midiNote)
	}

	panic = () => {
		this.oscillator1.panic()
		this.oscillator2.panic()
	}

	setMasterVolumeGain = (masterVolumeGain) => {
		const vol =  masterVolumeGain / 100
		this.state.amp.level = vol
		this.masterVolume.gain.value = vol

	}

	setOscillatorsBalance = (oscillatorsBalance) => {
		const gainPercentage = Math.abs(oscillatorsBalance) / 100
		this.oscillator1Gain.gain.value = .5
		this.oscillator2Gain.gain.value = .5

		if (oscillatorsBalance > 0) {
			this.oscillator1Gain.gain.value -= gainPercentage
			this.oscillator2Gain.gain.value += gainPercentage
		} else if (oscillatorsBalance < 0) {
			this.oscillator1Gain.gain.value += gainPercentage
			this.oscillator2Gain.gain.value -= gainPercentage
		}
		this.state.oscs.osc1.gain = this.oscillator1Gain.gain.value
		this.state.oscs.osc2.gain = this.oscillator2Gain.gain.value
	}

	setOscillator2Semitone = (oscillatorSemitone) => {
		this.state.oscs.osc2.semitone = oscillatorSemitone
		this.oscillator2.setSemitone(oscillatorSemitone)
	}

	setOscillator2Detune = (oscillatorDetune) => {
		this.state.oscs.osc2.detune = oscillatorDetune
		this.oscillator2.setDetune(oscillatorDetune)
	}

	setFmAmount = (fmAmount) => {
		const amount = 10 * fmAmount
		this.state.oscs.osc1.fmGain = amount
		for (let i = 0; i < CONSTANTS.MAX_NOTES ; i++) {
			this.fmGains[i].gain.value = amount
		}
	}

	setPulseWidth = (pulseWith) => {
		const pw = pulseWith / 100

		this.state.oscs.pw = pw
		this.oscillator2.setPulseWidth(pw)
	}

	setOscillator1Waveform = (waveform) => {
		const validWaveforms = [
			CONSTANTS.WAVEFORM_TYPE.SINE,
			CONSTANTS.WAVEFORM_TYPE.TRIANGLE,
			CONSTANTS.WAVEFORM_TYPE.SAWTOOTH,
			CONSTANTS.WAVEFORM_TYPE.SQUARE
		]

		const nextWaveform = waveform.toLowerCase()

		if (validWaveforms.indexOf(nextWaveform) == -1)
			throw new Error(`Invalid Waveform Type ${nextWaveform}`)

		this.oscillator1.setWaveform(nextWaveform)

	}


	setOscillator2Waveform = (waveform) => {
		const validWaveforms = [
			CONSTANTS.WAVEFORM_TYPE.TRIANGLE,
			CONSTANTS.WAVEFORM_TYPE.SAWTOOTH,
			CONSTANTS.WAVEFORM_TYPE.SQUARE,
			CONSTANTS.WAVEFORM_TYPE.NOISE
		]


		const nextWaveform = waveform.toLowerCase()

		if (validWaveforms.indexOf(nextWaveform) == -1)
			throw new Error(`Invalid Waveform Type ${nextWaveform}`)

		if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
				&& nextWaveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {

			if (nextWaveform ===  CONSTANTS.WAVEFORM_TYPE.SQUARE) {
				this.swapOsc2(new PulseOscillator(this.context),
					this.oscillator2Gain)
			}
			else
				this.oscillator2.setWaveform(nextWaveform)
		}
		else if(this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
				&& nextWaveform === CONSTANTS.WAVEFORM_TYPE.NOISE) {

			this.swapOsc2(new NoiseOscillator(this.context),
				this.oscillator2Gain)
		}
		else if(this.oscillator2.type === CONSTANTS.WAVEFORM_TYPE.NOISE
				&& nextWaveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {
			this.swapOsc2(
				new Oscillator(this.context, nextWaveform),
				this.oscillator2Gain
			)
		}
		this.state.oscs.osc2.waveformType = nextWaveform
	}

	swapOsc2 = (osc, gainB) => {
		const now = this.context.currentTime
		for (const midiNote in this.oscillator2.oscillators) {
			if (this.oscillator2.oscillators.hasOwnProperty(midiNote)) {
				osc.noteOn(midiNote)
				this.oscillator2.noteOff(now, midiNote)
			}
		}
		this.oscillator2 = osc
		this.oscillator2.setPulseWidth(this.state.oscs.pw)
		this.oscillator2.setDetune(this.state.oscs.osc2.detune)
		this.oscillator2.setKbdTrack(this.state.oscs.osc2.kbdTrack)
		this.oscillator2.setSemitone(this.state.oscs.osc2.semitone)

		this.oscillator2.oscillatorGains.map((oscGain, i) =>
			oscGain.connect(this.fmGains[i])
		)
		this.oscillator2.connect(gainB)
	}

	//god this is ugly
	swapOsc1 = (osc, gainB) => {
		const now = this.context.currentTime
		for (const midiNote in this.oscillator1.oscillators) {
			if (this.oscillator1.oscillators.hasOwnProperty(midiNote)) {
				osc.noteOn(midiNote)
				this.oscillator1.noteOff(now, midiNote)
			}
		}
		this.oscillator1 = osc

		//for(let i = 0 ; i < CONSTANTS.MAX_NOTES ; i++)
		//	this.fmGains[i].gain.value = this.state.oscs.osc1.fmGain

		this.oscillator1.oscillatorGains.map((oscGain, i) =>
			oscGain.connect(this.fmGains[i])
		)
		this.oscillator1.connect(gainB)
	}


	setFilterCutoff = (freq) => {
		this.filter.frequency.value = freq
	}


	setFilterQ = (q) => {
		this.filter.Q.value = q
	}

	setOscillator2KbdTrack = (state) => {
		this.state.oscs.osc2.kbdTrack = state
		this.oscillator2.setKbdTrack(state)
	}

	setFilterType = (filterType) => {
		const validFilterTypes = [
			CONSTANTS.FILTER_TYPE.LOWPASS, 
			CONSTANTS.FILTER_TYPE.HIGHPASS, 
			CONSTANTS.FILTER_TYPE.BANDPASS, 
			CONSTANTS.FILTER_TYPE.NOTCH
		]

		const filterType_ = filterType.toLowerCase()

		if (validFilterTypes.indexOf(filterType_) == -1){
			throw new Error('Invalid Filter Type')
		}

		this.filter.type = filterType_
	}

}