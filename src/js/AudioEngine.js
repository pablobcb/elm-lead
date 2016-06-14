import Oscillator from './Oscillator'

export default class AudioEngine {
	constructor () {
		this.context = new AudioContext

		this.initializeMasterVolume()

		this.initializeOscillators ()

		this.initializeOscillatorsGain ()

		this.initializeFMGain ()
	}
	
	initializeMasterVolume = () => {
		this.masterVolume = this.context.createGain()
		this.masterVolume.gain.value = 0.1
		this.masterVolume.connect(this.context.destination)
	}

	initializeOscillators = () => {
		this.oscillator1 = new Oscillator(this.context)
		this.oscillator2 = new Oscillator(this.context)
	}

	initializeOscillatorsGain = () => {
		this.oscillator1Gain = this.context.createGain()
		this.oscillator1Gain.gain.value = .5
		this.oscillator1Gain.connect(this.masterVolume)
		this.oscillator1.connect(this.oscillator1Gain)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = .5
		this.oscillator2Gain.connect(this.masterVolume)
		this.oscillator2.connect(this.oscillator2Gain)
	}

	initializeFMGain  = () => {
		//this.fmGain = this.context.createGain()
		//this.fmGain.gain.value = 0
		/*this.oscillator2.connect(this.fmGain)
		this.fmGain.connect(this.oscillator1.frequency)*/
	}

	onMIDIMessage  = (data) => {
		//console.log(data)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf

		// channel agnostic message type
		const type = data[0] & 0xf0
		const note = data[1]
		const velocity = data[2]

		switch (type) {
			case 144:
				this.noteOn(note, velocity)
				break
			case 128:
				this.noteOff(note, velocity)
				break
		}
	}

	noteOn = (midiNote /*, velocity*/) => {
		this.oscillator1.noteOn(midiNote)
		this.oscillator2.noteOn(midiNote)

		console.log(this.oscillator2.oscillators)
		console.log(this.oscillator1.frequency)
		this.oscillator2.oscillators[midiNote.toString()]
			.connect(this.oscillator1.frequency[midiNote.toString()])
	}

	noteOff = (midiNote /*, velocity*/) => {
		console.log(this.oscillator2.oscillators)
		console.log(this.oscillator1.frequency)
		this.oscillator2.oscillators[midiNote.toString()]
			.disconnect(this.oscillator1.frequency[midiNote.toString()])

		this.oscillator1.noteOff(midiNote)
		this.oscillator2.noteOff(midiNote)
	}

	panic = () => {
		this.oscillator1.panic()
		this.oscillator2.panic()
	}

	setMasterVolumeGain = (masterVolumeGain) => {
		this.masterVolume.gain.value = masterVolumeGain / 100
	}

	setOscillatorsBalance = (oscillatorsBalance) => {
		const gainPercentage = Math.abs(oscillatorsBalance) / 100

		this.oscillator1Gain.gain.value = .5
		this.oscillator2Gain.gain.value = .5

		if(oscillatorsBalance > 0) {
			this.oscillator1Gain.gain.value -= gainPercentage
			this.oscillator2Gain.gain.value += gainPercentage
		}
		else if(oscillatorsBalance < 0) {
			this.oscillator1Gain.gain.value += gainPercentage
			this.oscillator2Gain.gain.value -= gainPercentage
		}
	}

	setOscillator2Semitone = (oscillatorSemitone) => {
		this.oscillator2.setSemitone(oscillatorSemitone)
	}

	setOscillator2Detune = (oscillatorDetune) => {
		this.oscillator2.setDetune(oscillatorDetune)
	}

	setFmAmount = (fmAmount) => {
		this.oscillator1.setFMGain(fmAmount * 10)
	}

	setPulseWidth = (pulseWith)  => {
		this.oscillator1.setPulseWidth(pulseWith / 100)
		this.oscillator2.setPulseWidth(pulseWith / 100)
	}

	setOscillator1Waveform = (waveform)  => {
		const validWaveforms = ['sine', 'triangle', 'sawtooth', 'square']
		const waveform_ = waveform.toLowerCase()

		if(validWaveforms.indexOf(waveform_) == -1)
			throw new Error('Invalid Waveform Type')

		this.oscillator1.setWaveform(waveform_)
	}

	setOscillator2Waveform = (waveform)  => {
		const validWaveforms = ['triangle', 'sawtooth', 'square']
		const waveform_ = waveform.toLowerCase()

		if(validWaveforms.indexOf(waveform_) == -1)
			throw new Error('Invalid Waveform Type')

		this.oscillator2.setWaveform(waveform_)
	}
}
