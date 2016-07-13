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
		this.synth.setState(nextPreset)
		this.app.ports.presetChange.send(nextPreset)
	}

	previousPreset = () => {
		const previousPreset = this.presetManager.previous()
		this.synth.setState(previousPreset)
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

		this.synth = new Synth()
		this.synth.setState(preset)

		// MACRO
		window.onblur = () => {
			this.app.ports.panic.send()
			this.synth.oscillator1.panic()
			this.synth.oscillator2.panic()
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
		this.app.ports.oscsMix
			.subscribe(this.synth.mixer.setState)

		this.app.ports.osc2Semitone
			.subscribe(this.synth.oscillator2.setSemitone)

		this.app.ports.osc2Detune
			.subscribe(this.synth.oscillator2.setDetune)

		this.app.ports.fmAmount
			.subscribe(this.synth.oscillator1.setFmAmount)

		this.app.ports.pulseWidth
			.subscribe(this.synth.oscillator2.setPulseWidth)

		this.app.ports.osc1Waveform
			.subscribe(this.synth.oscillator1.setWaveform)

		this.app.ports.osc2Waveform
			.subscribe(this.synth.oscillator2.setWaveform)

		this.app.ports.osc2KbdTrack
			.subscribe(this.synth.oscillator2.toggleKbdTrack)

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
