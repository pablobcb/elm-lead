import Oscillator from './Oscillator'
import NoiseOscillator from './NoiseOscillator'
import CONSTANTS from './Constants'

export default class AudioEngine {
	constructor () {
		this.context = new AudioContext

		this.panelState = { 
			filter : {}, 
			amp: {},
			oscs: {}
		}

		this.initializeMasterVolume()

		this.initializeFilter()

		this.initializeOscillators()

		this.initializeOscillatorsGain()

		this.initializeFMGain()

		
	}

	initializeMasterVolume = () => {
		const initialAmpLevel =  0.1
		this.masterVolume = this.context.createGain()

		this.masterVolume.gain.value = initialAmpLevel
		this.panelState.amp.level = initialAmpLevel

		this.masterVolume.connect(this.context.destination)
	}

	initializeFilter = () => {
		const initialFreq = 12000
		this.filter = this.context.createBiquadFilter()

		this.panelState.filter.type = CONSTANTS.FILTER_TYPE.LOWPASS
		this.filter.type = CONSTANTS.FILTER_TYPE.LOWPASS

		this.filter.frequency.value = initialFreq
		this.panelState.filter.frequency = initialFreq
		
		this.filter.connect(this.masterVolume)
	}

	initializeOscillators = () => {
		this.panelState.oscs.osc1WaveformType = CONSTANTS.WAVEFORM_TYPE.SINE
		this.oscillator1 = new Oscillator(this.context,
			CONSTANTS.WAVEFORM_TYPE.SINE)
		
		this.panelState.oscs.osc1WaveformType = CONSTANTS.WAVEFORM_TYPE.TRIANGLE
		this.oscillator2 = new Oscillator(this.context,
			CONSTANTS.WAVEFORM_TYPE.TRIANGLE)

	}

	initializeOscillatorsGain = () => {
		const initialGain = .5
		this.oscillator1Gain = this.context.createGain()
		this.oscillator1Gain.gain.value = initialGain		
		this.oscillator1Gain.connect(this.filter)
		this.oscillator1.connect(this.oscillator1Gain)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = initialGain
		this.oscillator2Gain.connect(this.filter)
		this.oscillator2.connect(this.oscillator2Gain)

		this.panelState.oscs.osc1Gain = initialGain
		this.panelState.oscs.osc2Gain = initialGain
	}

	initializeFMGain = () => {
		this.fmGains = []

		for (let i = 0; i < 128; i++) {
			this.fmGains[i] = this.context.createGain()
			this.fmGains[i].gain.value = 0

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
		this.panelState.amp.level = vol
		this.masterVolume.gain.value = vol

	}

	setOscillatorsBalance = (oscillatorsBalance) => {
		const gainPercentage = Math.abs(oscillatorsBalance) / 100

		//is this necessary? initOscGain does it already
		this.oscillator1Gain.gain.value = .5
		this.oscillator2Gain.gain.value = .5

		if (oscillatorsBalance > 0) {
			this.oscillator1Gain.gain.value -= gainPercentage
			this.oscillator2Gain.gain.value += gainPercentage
		}
		else if (oscillatorsBalance < 0) {
			this.oscillator1Gain.gain.value += gainPercentage
			this.oscillator2Gain.gain.value -= gainPercentage
		}
		this.panelState.oscs.osc1Gain = this.oscillator1Gain.gain.value
		this.panelState.oscs.osc2Gain = this.oscillator1Gain.gain.value
	}

	setOscillator2Semitone = (oscillatorSemitone) => {
		this.panelState.oscs.osc2Semitone = oscillatorSemitone
		this.oscillator2.setSemitone(oscillatorSemitone)
	}

	setOscillator2Detune = (oscillatorDetune) => {
		this.panelState.oscs.osc2Detune = oscillatorDetune
		this.oscillator2.setDetune(oscillatorDetune)
	}

	setFmAmount = (fmAmount) => {
		for (let i = 0; i < 128; i++) {
			this.fmGains[i].gain.value = 10 * fmAmount
		}
	}

	//setPulseWidth = (pulseWith) => {
	//	this.oscillator1.setPulseWidth(pulseWith / 100)
	//	this.oscillator2.setPulseWidth(pulseWith / 100)
	//}

	setOscillator1Waveform = (waveform) => {
		const validWaveforms = [
			CONSTANTS.WAVEFORM_TYPE.SINE,
			CONSTANTS.WAVEFORM_TYPE.TRIANGLE, 
			CONSTANTS.WAVEFORM_TYPE.SAWTOOTH, 
			CONSTANTS.WAVEFORM_TYPE.SQUARE
		]
		
		const waveform_ = waveform.toLowerCase()
		
		if (validWaveforms.indexOf(waveform_) == -1)
			throw new Error(`Invalid Waveform Type ${waveform_}`)

		this.oscillator1.setWaveform(waveform_)
	}


	setOscillator2Waveform = (waveform) => {
		const validWaveforms = [
			CONSTANTS.WAVEFORM_TYPE.TRIANGLE, 
			CONSTANTS.WAVEFORM_TYPE.SAWTOOTH, 
			CONSTANTS.WAVEFORM_TYPE.SQUARE,
			CONSTANTS.WAVEFORM_TYPE.NOISE
		]


		const waveform_ = waveform.toLowerCase()

		if (validWaveforms.indexOf(waveform_) == -1)
			throw new Error(`Invalid Waveform Type ${waveform_}`)

		if(this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
			&& waveform_ !== CONSTANTS.WAVEFORM_TYPE.NOISE ){
				this.oscillator2.setWaveform(waveform_)
		}
		else if(this.oscillator2.type !== CONSTANTS.WAVEFORM_TYPE.NOISE
			&& waveform_ === CONSTANTS.WAVEFORM_TYPE.NOISE ){
				this.oscillator2 = new NoiseOscillator(this.context)
				this.oscillator2.connect(this.oscillator2Gain)
				this.oscillator2.oscillatorGains.map((oscGain, i) =>
					oscGain.connect(this.fmGains[i])
				)
		}
		else if(this.oscillator2.type === CONSTANTS.WAVEFORM_TYPE.NOISE
			&& waveform_ !== CONSTANTS.WAVEFORM_TYPE.NOISE ){
				this.oscillator2 =  new Oscillator(this.context, waveform_)
				this.oscillator2.oscillatorGains.map((oscGain, i) =>
					oscGain.connect(this.fmGains[i])
				)
				this.oscillator2.connect(this.oscillator2Gain)
		}
				
	}


	setFilterCutoff = (freq) => {
		this.filter.frequency.value = freq
	}


	setFilterQ = (q) => {
		this.filter.Q.value = q
	}

	setFilterType = (filterType) => {
		const validFilterTypes = [
			CONSTANTS.FILTER_TYPE.LOWPASS, 
			CONSTANTS.FILTER_TYPE.HIGHPASS, 
			CONSTANTS.FILTER_TYPE.BANDPASS, 
			CONSTANTS.FILTER_TYPE.NOTCH
		]

		const filterType_ = filterType.toLowerCase()

		if (validFilterTypes.indexOf(filterType_) == -1)
			throw new Error('Invalid Filter Type')

		this.filter.type = filterType_
	}
}
