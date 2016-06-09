import Elm from './Main.elm'

import AudioEngine from './AudioEngine'

export default class Application {

	constructor () {
		this.app = Elm.Main.fullscreen()
		this.midiAcess = null
		if (navigator.requestMIDIAccess) {
			navigator
				.requestMIDIAccess()
				.then((this.onMIDISuccess.bind(this)), this.onMIDIFailure)
				.then(this.initializeAudioEngine.bind(this))
		} else {
			this.onMIDIFailure({})
		}
	}

	initializeAudioEngine = () => {

		this.audioEngine = new AudioEngine(this.midiAccess)

		this.app.ports.midiPort.subscribe((midiData : Array<number>) => {
			const midiEvent = new Event('idimessage')
			midiEvent.data = midiData
			this.audioEngine.onMIDIMessage(midiEvent)
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
			this.audioEngine.setSetFmAmount(fmAmount)
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

	onMIDISuccess = (midiAccess : MIDIAccess) => {
		this.midiAccess = midiAccess
	}

	onMIDIFailure (e) {
		console.log(`No access to MIDI devices or your browser doesn\'t \
			support WebMIDI API. Please use WebMIDIAPIShim ${e}`)
	}

}
