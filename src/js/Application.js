import Elm from '../elm/Main.elm'

import AudioEngine from './AudioEngine/SynthEngine'

export default class Application {

	constructor () {
		this.app = Elm.Main.fullscreen()
		this.midiAcess = null
		if (navigator.requestMIDIAccess) {
			navigator
				.requestMIDIAccess()
				.then(this.onMIDISuccess.bind(this), this.onMIDIFailure)
				.then(this.initializeAudioEngine.bind(this))
		} else {
			this.onMIDIFailure()
		}
	}

	onMIDISuccess = (midiAccess) => {
		this.midiAccess = midiAccess
	}

	onMIDIFailure = () => {
		alert('Your browser doesnt support WebMIDI API. Use another browser or \
			install the Jazz Midi Plugin http://jazz-soft.net/')
	}

	initializeMidiAccess = () => {
		// loop over all available inputs and listen for any MIDI input
		for (const input of this.midiAccess.inputs.values()) {
			input.onmidimessage = (midiMessage) => {
				const data = midiMessage.data
				this.audioEngine.onMIDIMessage(data)
				this.app.ports.midiIn.send([
					data[0],
					data[1] || null,
					data[2] || null
				])
			}
		}
	}

	initializeAudioEngine = () => {

		this.audioEngine = new AudioEngine()
		// MACRO

		window.onblur = () => {
			this.app.ports.panic .send()
			this.audioEngine.panic()
		}

		// MIDI
		if (this.midiAccess) {
			this.initializeMidiAccess()
		}

		this.app.ports.midiOut
			.subscribe((midiDataArray) => {
				this.audioEngine.onMIDIMessage(midiDataArray)
			})

		// AMP
		this.app.ports.ampVolume
			.subscribe((masterVolumeValue) => {
				this.audioEngine.setMasterVolumeGain(masterVolumeValue)
			})

		this.app.ports.ampAttack
			.subscribe((attackValue) => {
				console.log(attackValue)
				//this.audioEngine.setAmpAttack(attackValue)
			})

		this.app.ports.ampDecay
			.subscribe((decayValue) => {
				console.log(decayValue)
				//this.audioEngine.setAmpDecay(decayValue)
			})

		this.app.ports.ampSustain
			.subscribe((sustainLevel) => {
				console.log(sustainLevel)
				//this.audioEngine.setAmpSustain(sustainLevel)
			})

		// OSCILLATORS

		this.app.ports.oscillatorsBalance
			.subscribe((oscillatorsBalanceValue) => {
				this.audioEngine.setOscillatorsBalance(oscillatorsBalanceValue)
			})

		this.app.ports.oscillator2Semitone
			.subscribe((oscillatorSemitoneValue) => {
				this.audioEngine.setOscillator2Semitone(oscillatorSemitoneValue)
			})

		this.app.ports.oscillator2Detune
			.subscribe((oscillatorDetuneValue) => {
				this.audioEngine.setOscillator2Detune(oscillatorDetuneValue)
			})

		this.app.ports.fmAmount
			.subscribe((fmAmountValue) => {
				this.audioEngine.setFmAmount(fmAmountValue)
			})

		this.app.ports.pulseWidth
			.subscribe((pulseWidthValue) => {
				this.audioEngine.setPulseWidth(pulseWidthValue)
			})

		this.app.ports.oscillator1Waveform
			.subscribe((waveform) => {
				this.audioEngine.setOscillator1Waveform(waveform)
			})

		this.app.ports.oscillator2Waveform
			.subscribe((waveform) => {
				this.audioEngine.setOscillator2Waveform(waveform)
			})

		// FILTER
		this.app.ports.filterCutoff
			.subscribe((freq) => {
				this.audioEngine.setFilterCutoff(freq)
			})

		this.app.ports.filterQ
			.subscribe((amount) => {
				this.audioEngine.setFilterQ(amount)
			})

		this.app.ports.filterType
			.subscribe((filterType) => {
				this.audioEngine.setFilterType(filterType)
			})
	}

}
