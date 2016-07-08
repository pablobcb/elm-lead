import Synth from './AudioEngine/Synth'
import MIDI from './MIDI'
import PresetManager from './PresetManager'
import { FilterState } from './AudioEngine/Filter'
import { AmplifierState } from './AudioEngine/Amplifier'
import { OscillatorsState } from './AudioEngine/Oscillators'

const Elm: any = require('../elm/Main.elm')

const presets = require('../presets.json') as Array<Preset>

const scaleMidiValue = (midiValue: number) =>
	MIDI.logScaleToMax(midiValue, 1)
const noMidiMsg = `Your browser doesnt support WebMIDI API. Use another
	browser or install the Jazz Midi Plugin http://jazz-soft.net/`

interface Preset {
	name: string
	presetId: number
	filter: FilterState
	amp: AmplifierState
	oscs: OscillatorsState
	overdrive: boolean
}

const midiSettingsToSynthSettings = (preset: Preset) => {
		let state = {
			amp: { adsr: {} },
			filter: { adsr: {} },
			oscs: { osc1: {}, osc2: {} }
		} as Preset
		/* META */
		//displayed name

		/* AMP */
		state.amp.adsr.attack =
			scaleMidiValue(preset.amp.adsr.attack)

		state.amp.adsr.decay =
			scaleMidiValue(preset.amp.adsr.decay)

		state.amp.adsr.sustain =
			scaleMidiValue(preset.amp.adsr.sustain)

		state.amp.adsr.release =
			scaleMidiValue(preset.amp.adsr.release)

		state.amp.masterVolume =
			scaleMidiValue(preset.amp.masterVolume)

		/* OVERDRIVE */
		state.overdrive =
			preset.overdrive

		/* FILTER */
		state.filter.type_ =
			preset.filter.type_

		state.filter.envelopeAmount =
			scaleMidiValue(preset.filter.envelopeAmount)

		state.filter.q =
			MIDI.toFilterQAmount(preset.filter.q)

		state.filter.frequency =
			MIDI.toFilterCutoffFrequency(preset.filter.frequency)

		state.filter.adsr.attack =
			scaleMidiValue(preset.filter.adsr.attack)

		state.filter.adsr.decay =
			scaleMidiValue(preset.filter.adsr.decay)

		state.filter.adsr.sustain =
			scaleMidiValue(preset.filter.adsr.sustain)

		state.filter.adsr.release =
			scaleMidiValue(preset.filter.adsr.release)

		/* OSC */
		state.oscs.pw =
			MIDI.logScaleToMax(preset.oscs.pw, .9)

		state.oscs.mix =
			MIDI.normalizeValue(preset.oscs.mix)

		state.oscs.osc1.waveformType =
			preset.oscs.osc1.waveformType

		state.oscs.osc1.fmGain =
			preset.oscs.osc1.fmGain

		state.oscs.osc2.waveformType =
			preset.oscs.osc2.waveformType

		state.oscs.osc2.semitone =
			preset.oscs.osc2.semitone

		state.oscs.osc2.detune =
			preset.oscs.osc2.detune

		state.oscs.osc2.kbdTrack =
			preset.oscs.osc2.kbdTrack

		return state
	}

export default class Application {

	private app: ElmComponent<any>
	private midiAccess: WebMidi.MIDIAccess
	private synth: Synth
	private presetManager: PresetManager<Preset>

	constructor() {
		const onMIDISuccess = (midiAccess: WebMidi.MIDIAccess) => {
			this.midiAccess = midiAccess
		}

		if (navigator.requestMIDIAccess) {
			navigator
				.requestMIDIAccess({ sysex: false })
				.then(onMIDISuccess, () => alert(noMidiMsg))
				.then(this.initializeSynth)
		} else {
			alert(noMidiMsg)
		}
	}

	nextPreset = () => {
		const nextPreset = this.presetManager.next()
		const synthState = midiSettingsToSynthSettings(nextPreset)
		this.synth.setState(synthState)
		this.app.ports.presetChange.send(nextPreset)
	}

	previousPreset = () => {
		const previousPreset = this.presetManager.previous()
		const synthState = midiSettingsToSynthSettings(previousPreset)
		this.synth.setState(synthState)
		this.app.ports.presetChange.send(previousPreset)
	}

	initializeSynth = () => {
		this.presetManager = new PresetManager<Preset>(presets)
		const preset = this.presetManager.current()
		const midiSupport = this.midiAccess ? true : false

		this.app = Elm.Main.fullscreen({
			preset: preset,
			midiSupport: midiSupport
		})

		//const synthSettings = midiSettingsToSynthSettings(preset)
		this.synth = new Synth(preset)

		// MACRO
		window.onblur = () => {
			this.app.ports.panic.send()
			this.synth.oscillators.panic()
		}

		window.oncontextmenu = () => false

		this.app.ports.previousPreset
			.subscribe(() => {
				this.previousPreset()
			})

		this.app.ports.nextPreset
			.subscribe(() => {
				this.nextPreset()
			})

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
			.subscribe(this.synth.overdrive.setState)


		// MIDI
		if (this.midiAccess) {
			MIDI.manageMidiDevices(
				this.synth.onMIDIMessage,
				this.midiAccess,
				this.app.ports.midiIn,
				this.app.ports.midiStateChange
			)
		}

		this.app.ports.midiOut.subscribe(this.synth.onMIDIMessage)

	}
}
