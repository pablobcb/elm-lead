import Elm from '../elm/Main.elm'

import Synth from './AudioEngine/Synth'
import MIDI from './MIDI'
import PresetManager from './PresetManager'

export default class Application {

	constructor () {
		this.app = Elm.Main.fullscreen(PresetManager.loadPreset())
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

	onMIDISuccess = midiAccess => {
		this.midiAccess = midiAccess
	}

	onMIDIpresetFailure = () => {
		alert('Your browser doesnt support WebMIDI API. Use another browser or \
			install the Jazz Midi Plugin http://jazz-soft.net/')
	}

	initializeSynth = () => {

		this.synth = new Synth(PresetManager.midiSettingsToSynthSettings())

		// this pernicious hack is necessary, see 
		// https://github.com/elm-lang/core/issues/595
		// setTimeout(() => this.app.ports.presetChange.send(preset), 0)
		// MACRO

		window.onblur = () => {
			this.app.ports.panic.send()
			this.synth.panic()
		}

		window.oncontextmenu = () => false

		// AMP
		this.app.ports.ampVolume
			.subscribe(this.synth.setMasterVolumeGain)

		this.app.ports.ampAttack
			.subscribe(this.synth.setAmpAttack)

		this.app.ports.ampDecay
			.subscribe(this.synth.setAmpDecay)

		this.app.ports.ampSustain
			.subscribe(this.synth.setAmpSustain)

		this.app.ports.ampRelease
			.subscribe(this.synth.setAmpRelease)

		// OSCILLATORS

		this.app.ports.oscsBalance
			.subscribe(this.synth.setOscillatorsMix)

		this.app.ports.osc2Semitone
			.subscribe(this.synth.setOscillator2Semitone)

		this.app.ports.osc2Detune
			.subscribe(this.synth.setOscillator2Detune)

		this.app.ports.fmAmount
			.subscribe(this.synth.setFmAmount)

		this.app.ports.pulseWidth
			.subscribe(this.synth.setPulseWidth)

		this.app.ports.osc1Waveform
			.subscribe(this.synth.setOscillator1Waveform)

		this.app.ports.osc2Waveform
			.subscribe(this.synth.setOscillator2Waveform)

		this.app.ports.osc2KbdTrack
			.subscribe(this.synth.toggleOsc2KbdTrack)

		// FILTER
		this.app.ports.filterEnvelopeAmount
			.subscribe(this.synth.filter.setEnvelopeAmount)

		this.app.ports.filterAttack
			.subscribe(this.synth.filter.setAttack)

		this.app.ports.filterDecay
			.subscribe(this.synth.filter.setDecay)

		this.app.ports.filterSustain
			.subscribe(this.synth.filter.setSustain)

		this.app.ports.filterRelease
			.subscribe(this.synth.filter.setRelease)

		this.app.ports.filterCutoff
			.subscribe(this.synth.filter.setCutoff)

		this.app.ports.filterQ
			.subscribe(this.synth.filter.setQ)

		this.app.ports.filterType
			.subscribe(this.synth.filter.setType)

		this.app.ports.filterDistortion
			.subscribe(this.synth.filter.toggleDistortion)


		// MIDI
		if (this.midiAccess) {
			MIDI.manageMidiDevices(this.midiAccess,
				this.app.ports.midiIn, this.synth.onMIDIMessage)
		}

		this.app.ports.midiOut
			.subscribe(this.synth.onMIDIMessage)

	}
}
