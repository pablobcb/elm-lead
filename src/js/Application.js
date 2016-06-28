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
			.subscribe((masterVolumeValue) => {
				this.audioEngine.setMasterVolumeGain(masterVolumeValue)
			})

		this.app.ports.ampAttack
			.subscribe((attackValue) => {
				this.audioEngine.setAmpAttack(attackValue)
			})

		this.app.ports.ampDecay
			.subscribe((decayValue) => {
				this.audioEngine.setAmpDecay(decayValue)
			})

		this.app.ports.ampSustain
			.subscribe((sustainLevel) => {
				this.audioEngine.setAmpSustain(sustainLevel)
			})
		
		this.app.ports.ampRelease
			.subscribe((releaseLevel) => {
				this.audioEngine.setAmpRelease(releaseLevel)
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

		this.app.ports.oscillator2KbdTrack
			.subscribe((kbdTrackState) => {
				this.audioEngine.setOscillator2KbdTrack(kbdTrackState)
			})

		// FILTER
		this.app.ports.filterAttack
			.subscribe((attackValue) => {
				this.audioEngine.setFilterAttack(attackValue)
			})

		this.app.ports.filterDecay
			.subscribe((decayValue) => {
				this.audioEngine.setFilterDecay(decayValue)
			})

		this.app.ports.filterSustain
			.subscribe((sustainLevel) => {
				this.audioEngine.setFilterSustain(sustainLevel)
			})
		
		this.app.ports.filterRelease
			.subscribe((releaseLevel) => {
				this.audioEngine.setFilterRelease(releaseLevel)
			})

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
		
		// MIDI
		if (this.midiAccess) {
			MIDI.manageMidiDevices(this.midiAccess, 
			this.app.ports.midiIn, this.audioEngine.onMIDIMessage)
		}

		this.app.ports.midiOut
			.subscribe((midiDataArray) => {
				this.audioEngine.onMIDIMessage(midiDataArray)
			})

	}

}
