import Elm from '../elm/Main.elm'

import Synth from './AudioEngine/Synth'
import MIDI from './AudioEngine/MIDI'

export default class Application {

	constructor () {
		this.app = Elm.Main.fullscreen()
		this.midiAcess = null
		if (navigator.requestMIDIAccess) {
			navigator
				.requestMIDIAccess()
				.then(this.onMIDISuccess.bind(this), this.onMIDIFailure)
				.then(this.initializeSynth.bind(this))
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

	initializeSynth = () => {

		this.synth = new Synth()
		// MACRO

		window.onblur = () => {
			this.app.ports.panic.send()
			this.synth.panic()
		}

		// AMP
		this.app.ports.ampVolume.subscribe(this.synth.setMasterVolumeGain)

		this.app.ports.ampAttack.subscribe(this.synth.setAmpAttack)

		this.app.ports.ampDecay.subscribe(this.synth.setAmpDecay)

		this.app.ports.ampSustain.subscribe(this.synth.setAmpSustain)
		
		this.app.ports.ampRelease.subscribe(this.synth.setAmpRelease)

		// OSCILLATORS

		this.app.ports.oscillatorsBalance
			.subscribe(this.synth.setOscillatorsBalance)

		this.app.ports.oscillator2Semitone
			.subscribe(this.synth.setOscillator2Semitone)

		this.app.ports.oscillator2Detune
			.subscribe(this.synth.setOscillator2Detune)

		this.app.ports.fmAmount
			.subscribe(this.synth.setFmAmount)

		this.app.ports.pulseWidth
			.subscribe(this.synth.setPulseWidth)

		this.app.ports.oscillator1Waveform
			.subscribe(this.synth.setOscillator1Waveform)

		this.app.ports.oscillator2Waveform
			.subscribe(this.synth.setOscillator2Waveform)

		this.app.ports.oscillator2KbdTrack
			.subscribe(this.synth.setOscillator2KbdTrack)

		// FILTER
		this.app.ports.filterAttack
			.subscribe(this.synth.setFilterAttack)

		this.app.ports.filterDecay
			.subscribe(this.synth.setFilterDecay)

		this.app.ports.filterSustain
			.subscribe(this.synth.setFilterSustain)
		
		this.app.ports.filterRelease
			.subscribe(this.synth.setFilterRelease)

		this.app.ports.filterCutoff
			.subscribe(this.synth.setFilterCutoff)

		this.app.ports.filterQ
			.subscribe(this.synth.setFilterQ)


		this.app.ports.filterType
			.subscribe(this.synth.setFilterType)

		
		// MIDI
		if (this.midiAccess) {
			MIDI.manageMidiDevices(this.midiAccess, 
				this.app.ports.midiIn, this.synth.onMIDIMessage)
		}

		this.app.ports.midiOut
			.subscribe(this.synth.onMIDIMessage)

	}
}
