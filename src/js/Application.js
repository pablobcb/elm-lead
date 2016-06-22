import Elm from '../elm/Main.elm'

import AudioEngine from './AudioEngine'

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
		alert('Your browser doesnt support WebMIDI API. Use another browser or install the Jazz Midi Plugin http://jazz-soft.net/')
	}

	initializeMidiAccess = () => {
		// loop over all available inputs and listen for any MIDI input
		for (const input of this.midiAccess.inputs.values()) {
			input.onmidimessage = (midiMessage) => {
				const data = midiMessage.data
				this.audioEngine.onMIDIMessage(data)
				this.app.ports.midiInPort.send([
					data[0],
					data[1] || null,
					data[2] || null
				])
			}
		}
	}

	initializeAudioEngine = () => {

		this.audioEngine = new AudioEngine()

		// MIDI
		if(this.midiAccess)
			this.initializeMidiAccess()

		this.app.ports.midiOutPort
			.subscribe((midiDataArray) => {
				this.audioEngine.onMIDIMessage(midiDataArray)
			})

		// AMP
		this.app.ports.ampVolumePort
			.subscribe((masterVolumeValue) => {
				console.log(masterVolumeValue)
				//this.audioEngine.setMasterVolumeGain(masterVolumeValue)
			})
		
		this.app.ports.ampAttackVolumePort
			.subscribe((attackValue) => {
				console.log(attackValue)
				//this.audioEngine.setAmpAttack(attackValue)
			})
		
		this.app.ports.ampDecayVolumePort
			.subscribe((decayValue) => {
				console.log(decayValue)
				//this.audioEngine.setAmpDecay(decayValue)
			})

		this.app.ports.ampSustainVolumePort
			.subscribe((sustainLevel) => {
				console.log(sustainLevel)
				//this.audioEngine.setAmpSustain(sustainLevel)
			})

		// OSCILLATORS
		this.app.ports.oscillatorsBalancePort
			.subscribe((oscillatorsBalanceValue) => {
				this.audioEngine.setOscillatorsBalance(oscillatorsBalanceValue)
			})

		this.app.ports.oscillator2SemitonePort
			.subscribe((oscillatorSemitoneValue) => {
				this.audioEngine.setOscillator2Semitone(oscillatorSemitoneValue)
			})

		this.app.ports.oscillator2DetunePort
			.subscribe((oscillatorDetuneValue) => {
				this.audioEngine.setOscillator2Detune(oscillatorDetuneValue)
			})

		this.app.ports.fmAmountPort
			.subscribe((fmAmountValue) => {
				this.audioEngine.setFmAmount(fmAmountValue)
			})

		this.app.ports.pulseWidthPort
			.subscribe((pulseWidthValue) => {
				this.audioEngine.setPulseWidth(pulseWidthValue)
			})

		this.app.ports.oscillator1WaveformPort
			.subscribe((waveform) => {
				this.audioEngine.setOscillator1Waveform(waveform)
			})

		this.app.ports.oscillator2WaveformPort
			.subscribe((waveform) => {
				this.audioEngine.setOscillator2Waveform(waveform)
			})

		// FILTER
		this.app.ports.filterCutoffPort
			.subscribe((freq) => {
				this.audioEngine.setFilterCutoff(freq)
			})

		this.app.ports.filterQPort
			.subscribe((amount) => {
				this.audioEngine.setFilterQ(amount)
			})

		this.app.ports.filterTypePort
			.subscribe((filterType) => {
				this.audioEngine.setFilterType(filterType)
			})

		// MACRO
		window.onblur = () => {
			this.app.ports.panicPort.send()
			this.audioEngine.panic()
		}
	}

}
