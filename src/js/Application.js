import Elm from '../elm/Main.elm'

import AudioEngine from './AudioEngine/Synth'
import MIDI from './AudioEngine/MIDI'

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

	initializeAudioEngine = () => {

		this.audioEngine = new AudioEngine()
		// MACRO

		window.onblur = () => {
			this.app.ports.panic .send()
			this.audioEngine.panic()
		}

		// AMP
		this.app.ports.ampVolume
			.subscribe(this.audioEngine.setMasterVolumeGain)

		this.app.ports.ampAttack
			.subscribe(this.audioEngine.setAmpAttack)

		this.app.ports.ampDecay
			.subscribe(this.audioEngine.setAmpDecay)

		this.app.ports.ampSustain
			.subscribe(this.audioEngine.setAmpSustain)
		
		this.app.ports.ampRelease
			.subscribe(this.audioEngine.setAmpRelease)

		// OSCILLATORS

		this.app.ports.oscillatorsBalance
			.subscribe(this.audioEngine.setOscillatorsBalance)

		this.app.ports.oscillator2Semitone
			.subscribe(this.audioEngine.setOscillator2Semitone)

		this.app.ports.oscillator2Detune
			.subscribe(this.audioEngine.setOscillator2Detune)

		this.app.ports.fmAmount
			.subscribe(this.audioEngine.setFmAmount)

		this.app.ports.pulseWidth
			.subscribe(this.audioEngine.setPulseWidth)

		this.app.ports.oscillator1Waveform
			.subscribe(this.audioEngine.setOscillator1Waveform)

		this.app.ports.oscillator2Waveform
			.subscribe(this.audioEngine.setOscillator2Waveform)

		this.app.ports.oscillator2KbdTrack
			.subscribe(this.audioEngine.setOscillator2KbdTrack)

		// FILTER
		this.app.ports.filterAttack
			.subscribe(this.audioEngine.setFilterAttack)

		this.app.ports.filterDecay
			.subscribe(this.audioEngine.setFilterDecay)

		this.app.ports.filterSustain
			.subscribe(this.audioEngine.setFilterSustain)
		
		this.app.ports.filterRelease
			.subscribe(this.audioEngine.setFilterRelease)

		this.app.ports.filterCutoff
			.subscribe(this.audioEngine.setFilterCutoff)

		this.app.ports.filterQ
			.subscribe(this.audioEngine.setFilterQ)


		this.app.ports.filterType
			.subscribe(this.audioEngine.setFilterType)

		
		// MIDI
		if (this.midiAccess) {
			MIDI.manageMidiDevices(this.midiAccess, 
				this.app.ports.midiIn, this.audioEngine.onMIDIMessage)
		}

		this.app.ports.midiOut
			.subscribe(this.audioEngine.onMIDIMessage)

	}
}
