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
			this.synth.oscillators.panic()
		}

		window.oncontextmenu = () => false

		// AMP
		this.app.ports.ampVolume
			.subscribe(this.synth.amplifier.setMasterVolumeGain)

		this.app.ports.ampAttack
			.subscribe(this.synth.amplifier.adsr.setAttack)

		this.app.ports.ampDecay
			.subscribe(this.synth.amplifier.adsr.setDecay)

		this.app.ports.ampSustain
			.subscribe(this.synth.amplifier.adsr.setSustain)

		this.app.ports.ampRelease
			.subscribe(this.synth.amplifier.adsr.setRelease)

		// OSCILLATORS

		this.app.ports.oscsBalance
			.subscribe(this.synth.oscillators.setMix)

		this.app.ports.osc2Semitone
			.subscribe(this.synth.oscillators.setOscillator2Semitone)

		this.app.ports.osc2Detune
			.subscribe(this.synth.oscillators.setOscillator2Detune)

		this.app.ports.fmAmount
			.subscribe(this.synth.oscillators.setFmAmount)

		this.app.ports.pulseWidth
			.subscribe(this.synth.oscillators.setPulseWidth)

		this.app.ports.osc1Waveform
			.subscribe(this.synth.oscillators.setOscillator1Waveform)

		this.app.ports.osc2Waveform
			.subscribe(this.synth.oscillators.setOscillator2Waveform)

		this.app.ports.osc2KbdTrack
			.subscribe(this.synth.oscillators.toggleOsc2KbdTrack)

		// FILTER
		this.app.ports.filterEnvelopeAmount
			.subscribe(this.synth.filter.setEnvelopeAmount)

		this.app.ports.filterAttack
			.subscribe(this.synth.filter.adsr.setAttack)

		this.app.ports.filterDecay
			.subscribe(this.synth.filter.adsr.setDecay)

		this.app.ports.filterSustain
			.subscribe(this.synth.filter.adsr.setSustain)

		this.app.ports.filterRelease
			.subscribe(this.synth.filter.adsr.setRelease)

		this.app.ports.filterCutoff
			.subscribe(this.synth.filter.setCutoff)

		this.app.ports.filterQ
			.subscribe(this.synth.filter.setQ)

		this.app.ports.filterType
			.subscribe(this.synth.filter.setType)

		this.app.ports.overdrive
			.subscribe(this.synth.overdrive.toggle)


		// MIDI
		if (this.midiAccess) {
			MIDI.manageMidiDevices(
				this.synth.onMIDIMessage,
				this.midiAccess,
				this.app.ports.midiIn,
				this.app.ports.midiStateChange
			)
		}

		this.app.ports.midiOut
			.subscribe(this.synth.onMIDIMessage)

	}
}
