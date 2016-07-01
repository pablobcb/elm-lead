import FMOscillator from './Oscillator/FMOscillator'
import PulseOscillator from './Oscillator/PulseOscillator'
import NoiseOscillator from './Oscillator/NoiseOscillator'
import ADSR from './ADSR'
import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import PresetManager from '../PresetManager'


export default class Synth {
	constructor () {
		this.context = new AudioContext

		this.state = PresetManager.loadPresets()

		this.ampADSR = new ADSR(this.context, 1)

		this.initializeMasterOutput()

		this.initializeFilter()

		this.filterADSR = new ADSR(this.context,
			this.state.filter.envelopeAmount)

		this.oscillator1 = new FMOscillator(this.context,
			this.state.oscs.osc1.waveformType)

		this.oscillator2 = new FMOscillator(this.context,
			this.state.oscs.osc2.waveformType)

		this.initializeOscillatorsGain()

		this.initializeFMGain()

	}

	initializeMasterOutput = () => {
		this.masterVolume = this.context.createGain()

		this.masterVolume.gain.value = this.state.masterVolume
		this.masterVolume.connect(this.context.destination)
	}

	initializeFilter = () => {
		this.filterEnvelopeGain = this.context.createGain()
		this.filter = this.context.createBiquadFilter()
		this.filter.type = this.state.filter.type_
		this.filter.frequency.value = this.state.filter.frequency
		this.filter.Q.value = this.state.filter.q

		this.filter.connect(this.filterEnvelopeGain)
		this.filterEnvelopeGain.connect(this.masterVolume)
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

	onMIDIMessage = data => {
		//console.log(data)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf
		// channel agnostic message type
		const type = data[0] & 0xf0
		const note = data[1]
		const velocity = data[2]

		switch (type) {
			case CONSTANTS.MIDI_EVENT.NOTE_ON:
				this.noteOn(note, velocity)
				break
			case CONSTANTS.MIDI_EVENT.NOTE_OFF:
				this.noteOff(note, velocity)
				break
		}
	}

	noteOn = (midiNote /*, velocity*/) => {
		this.oscillator1.noteOn(midiNote,
			this.ampADSR.on(this.state.amp))
		this.oscillator2.noteOn(midiNote,
			this.ampADSR.on(this.state.amp))

		//this.state.filter.amp.on(this.filter.frequency,
		//	this.filter.frequency.value)

	}

	noteOff = (midiNote /*, velocity*/) => {
		this.oscillator1.noteOff(midiNote, this.ampADSR.off)
		this.oscillator2.noteOff(midiNote, this.ampADSR.off)

		//this.state.filter.off(this.filter.frequency)
	}

	panic = () => {
		this.oscillator1.panic()
		this.oscillator2.panic()
	}

	setMasterVolumeGain = midiValue => {
		const vol = MIDI.logScaleToMax(midiValue, 1)
		this.state.masterVolume = vol
		this.masterVolume.gain.value = vol
	}

	setOscillatorsBalance = oscillatorsBalance => {
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

	setOscillator2Semitone = oscillatorSemitone => {
		this.state.oscs.osc2.semitone = oscillatorSemitone
		this.oscillator2.setSemitone(oscillatorSemitone)
	}

	setOscillator2Detune = oscillatorDetune => {
		this.state.oscs.osc2.detune = oscillatorDetune
		this.oscillator2.setDetune(oscillatorDetune)
	}

	setFmAmount = fmAmount => {
		const amount = 10 * fmAmount

		this.state.oscs.osc1.fmGain = amount
		for (let i = 0; i < CONSTANTS.MAX_NOTES; i++) {
			this.fmGains[i].gain.value = amount
		}
	}

	setPulseWidth = midiValue => {
		const pw = MIDI.logScaleToMax(midiValue, .9)

		this.state.oscs.pw = pw
		this.oscillator2.setPulseWidth(pw)
	}

	setOscillator1Waveform = waveform => {
		const nextWaveform = waveform.toLowerCase()

		if (CONSTANTS.OSC1_WAVEFORM_TYPES.indexOf(nextWaveform) == -1) {
			throw new Error(`Invalid Waveform Type ${nextWaveform}`)
		}

		this.oscillator1.setWaveform(nextWaveform)
	}

	toggleOsc2KbdTrack = state => {
		this.state.oscs.osc2.kbdTrack = state
		this.oscillator2.setKbdTrack(state)
	}

	setOscillator2Waveform = waveform => {

		const nextWaveform = waveform.toLowerCase()

		if (CONSTANTS.OSC2_WAVEFORM_TYPES.indexOf(nextWaveform) == -1) {
			throw new Error(`Invalid Waveform Type ${nextWaveform}`)
		}

		if (this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
			&& nextWaveform !== CONSTANTS.WAVEFORM_TYPE.NOISE) {

			if (nextWaveform === CONSTANTS.WAVEFORM_TYPE.SQUARE) {
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
		this.state.oscs.osc2.waveformType = nextWaveform
	}

	swapOsc2 = (osc, gainB) => {
		const now = this.context.currentTime
		for (const midiNote in this.oscillator2.oscillators) {
			if (this.oscillator2.oscillators.hasOwnProperty(midiNote)) {
				this.oscillator2.noteOff(now, midiNote)
				osc.noteOn(midiNote)
			}
		}
		this.oscillator2.oscillatorGains.forEach((oscGain, i) =>
			oscGain.disconnect(this.fmGains[i])
		)
		this.oscillator2.disconnect(gainB)

		this.oscillator2 = osc
		this.oscillator2.setPulseWidth(this.state.oscs.pw)
		this.oscillator2.setDetune(this.state.oscs.osc2.detune)
		this.oscillator2.setKbdTrack(this.state.oscs.osc2.kbdTrack)
		this.oscillator2.setSemitone(this.state.oscs.osc2.semitone)

		this.oscillator2.oscillatorGains.forEach((oscGain, i) =>
			oscGain.connect(this.fmGains[i])
		)
		this.oscillator2.connect(gainB)
	}

	setFilterCutoff = midiValue => {
		this.filter.frequency.value = MIDI.toFilterCutoffFrequency(midiValue)
	}

	setFilterQ = midiValue => {
		this.filter.Q.value = MIDI.toFilterQAmount(midiValue)
	}

	setFilterType = filterType => {
		const filterType_ = filterType.toLowerCase()

		if (CONSTANTS.FILTER_TYPES.indexOf(filterType_) == -1) {
			throw new Error('Invalid Filter Type')
		}

		this.filter.type = filterType_
	}


	toggleFilterDistortion = state => {
		this.state.filter.distortion = state
	}

	setAmpAttack = midiValue => {
		this.state.amp.attack = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setAmpDecay = midiValue => {
		this.state.amp.decay = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setAmpSustain = midiValue => {
		this.state.amp.sustain = MIDI.logScaleToMax(midiValue, 1)
	}

	setAmpRelease = midiValue => {
		this.state.amp.release = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setAmpFilterEnvelopeAmount = midiValue => {
		this.maxAmount = MIDI.logScaleToMax(midiValue, 1)
	}
}