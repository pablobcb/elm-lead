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
	
	onMIDISuccess = (midiAccess : MIDIAccess) => {
		this.midiAccess = midiAccess
	}

	onMIDIFailure = () => {
		alert('Your browser doesnt support WebMIDI API. Use WebMIDIAPIShim')
	}
	
	initializeMidiAccess = () => {
		// loop over all available inputs and listen for any MIDI input
		for (const input of this.midiAccess.inputs.values()) {
			input.onmidimessage = (midiMessage) => {
				const data = midiMessage.data
				this.audioEngine.onMIDIMessage(data)
				this.app.ports.midiInPort.send([data[0],data[1],data[2]])
			}
		}
	}
	
	initializeAudioEngine = () => {

		this.audioEngine = new AudioEngine()

		if(this.midiAccess)
			this.initializeMidiAccess()

		this.app.ports.midiOutPort.subscribe((midiData : Array<number>) => {
			this.audioEngine.onMIDIMessage(midiData)
		})

		this.app.ports.masterVolumePort.subscribe((masterVolume : number) => {
			this.audioEngine.setMasterVolumeGain(masterVolume)
		})

		this.app.ports.oscillatorsBalancePort.subscribe((oscillatorsBalance : number) => {
			this.audioEngine.setOscillatorsBalance(oscillatorsBalance)
		})

		this.app.ports.oscillator2SemitonePort.subscribe((oscillatorSemitone : number) => {
			this.audioEngine.setOscillator2Semitone(oscillatorSemitone)
		})

		this.app.ports.oscillator2DetunePort.subscribe((oscillatorDetune : number) => {
			this.audioEngine.setOscillator2Detune(oscillatorDetune)
		})

		this.app.ports.fmAmountPort.subscribe((fmAmount : number) => {
			this.audioEngine.setFmAmount(fmAmount)
		})

		this.app.ports.pulseWidthPort.subscribe((pulseWidth : number) => {
			this.audioEngine.setPulseWidth(pulseWidth)
		})

		this.app.ports.oscillator1WaveformPort.subscribe((waveform) => {
			this.audioEngine.setOscillator1Waveform(waveform)
		})

		this.app.ports.oscillator2WaveformPort.subscribe((waveform) => {
			this.audioEngine.setOscillator2Waveform(waveform)
		})

		window.onblur = () => {
			this.audioEngine.panic()
		}
	}

}
