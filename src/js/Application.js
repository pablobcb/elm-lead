import Elm from '../elm/Main.elm'

import SynthEngine from './SynthEngine'

export default class Application {

	constructor () {
		this.app = Elm.Main.fullscreen()
		this.midiAcess = null
		if (navigator.requestMIDIAccess) {
			navigator
				.requestMIDIAccess()
				.then(this.onMIDISuccess.bind(this), this.onMIDIFailure)
				.then(this.initializesynthEngine.bind(this))
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
				this.synthEngine.onMIDIMessage(data)
				this.app.ports.midiInPort.send([
					data[0],
					data[1] || null,
					data[2] || null
				])
			}
		}
	}

	initializesynthEngine = () => {

		this.synthEngine = new SynthEngine()

		// MIDI
		if(this.midiAccess)
			this.initializeMidiAccess()

		this.app.ports.midiOutPort
			.subscribe((midiDataArray) => {
				this.synthEngine.onMIDIMessage(midiDataArray)
			})

		// VOLUME
		this.app.ports.masterVolumePort
			.subscribe((masterVolumeValue) => {
				console.log(masterVolumeValue)
				this.synthEngine.setMasterVolumeGain(masterVolumeValue)
			})

		// OSCILLATORS
		this.app.ports.oscillatorsBalancePort
			.subscribe((oscillatorsBalanceValue) => {
				this.synthEngine.setOscillatorsBalance(oscillatorsBalanceValue)
			})

		this.app.ports.oscillator2SemitonePort
			.subscribe((oscillatorSemitoneValue) => {
				this.synthEngine.setOscillator2Semitone(oscillatorSemitoneValue)
			})

		this.app.ports.oscillator2DetunePort
			.subscribe((oscillatorDetuneValue) => {
				this.synthEngine.setOscillator2Detune(oscillatorDetuneValue)
			})

		this.app.ports.fmAmountPort
			.subscribe((fmAmountValue) => {
				this.synthEngine.setFmAmount(fmAmountValue)
			})

		this.app.ports.pulseWidthPort
			.subscribe((pulseWidthValue) => {
				this.synthEngine.setPulseWidth(pulseWidthValue)
			})

		this.app.ports.oscillator1WaveformPort
			.subscribe((waveform) => {
				this.synthEngine.setOscillator1Waveform(waveform)
			})

		this.app.ports.oscillator2WaveformPort
			.subscribe((waveform) => {
				this.synthEngine.setOscillator2Waveform(waveform)
			})

		// FILTER
		this.app.ports.filterCutoffPort
			.subscribe((freq) => {
				this.synthEngine.setFilterCutoff(freq)
			})

		this.app.ports.filterQPort
			.subscribe((amount) => {
				this.synthEngine.setFilterQ(amount)
			})
		
		this.app.ports.filterTypePort
			.subscribe((filterType) => {
				this.synthEngine.setFilterType(filterType)
			})

		// MACRO
		window.onblur = () => {
			this.app.ports.panicPort.send()
			this.synthEngine.panic()
		}
	}

}
