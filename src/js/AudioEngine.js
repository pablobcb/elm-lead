import Oscillator from './Oscillator'

export default class AudioEngine {
	constructor () {
		this.context = new AudioContext

		this.initializeMasterVolume()

		this.initializeFilter()

		this.initializeOscillators ()

		this.initializeOscillatorsGain ()

		this.initializeFMGain ()
	}
	
	initializeMasterVolume = () => {
		this.masterVolume = this.context.createGain()
		this.masterVolume.gain.value = 0.1
		this.masterVolume.connect(this.context.destination)
	}

	initializeFilter = () => {
		this.filter = this.context.createBiquadFilter()
		this.filter.type = 'lowpass'
		this.filter.connect(this.masterVolume)
	}

	initializeOscillators = () => {
		this.oscillator1 = new Oscillator(this.context, 'sine')
		this.oscillator2 = new Oscillator(this.context, 'triangle')
	}

	initializeOscillatorsGain = () => {
		this.oscillator1Gain = this.context.createGain()
		this.oscillator1Gain.gain.value = .5
		this.oscillator1Gain.connect(this.filter)
		this.oscillator1.connect(this.oscillator1Gain)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = .5
		this.oscillator2Gain.connect(this.filter)
		this.oscillator2.connect(this.oscillator2Gain)
	}

	initializeFMGain  = () => {
		this.fmGains = []
		
		for(let i=0; i<128; i++) {
			this.fmGains[i] = this.context.createGain()
			this.fmGains[i].gain.value = 0
			this.oscillator2.oscillatorGains[i].connect(this.fmGains[i])
			this.fmGains[i].connect(this.oscillator1.frequencyGains[i])
		}
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
		for(let i=0; i<128; i++) {
			this.fmGains[i].gain.value = 10 * fmAmount
		}
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


	setFilterCutoff = (freq) => {
		this.filter.frequency.value = freq
	}


	setFilterQ = (q) => {
		this.filter.Q.value = q
	}
}
