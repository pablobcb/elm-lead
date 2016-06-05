import Elm from './Main.elm'

import AudioEngine from './AudioEngine'

export default class Application {

	constructor () {
		this.app = Elm.Main.fullscreen()

		if (navigator.requestMIDIAccess) {
			navigator
				.requestMIDIAccess()
				.then(this.onMIDISuccess.bind(this), this.onMIDIFailure)
		} else {
			alert('No MIDI support in your browser.')
		}
	}

	// this is our raw MIDI data, inputs, outputs, and sysex status
	onMIDISuccess (midiAccess : MIDIAccess) {
		this.audioEngine = new AudioEngine(midiAccess)

		this.app.ports.midiPort.subscribe((midiData : Array<number>) => {
			const midiEvent = new Event('idimessage')
			midiEvent.data = midiData
			this.audioEngine.onMIDIMessage(midiEvent)
		})

		this.app.ports.masterVolumePort.subscribe((masterVolume : number) => {
			this.audioEngine.setMasterVolumeGain(masterVolume)
		})

		this.app.ports.oscillatorsBalancePort
			.subscribe((oscillatorsBalance : number) => {
				this.audioEngine.setOscillatorsBalance(oscillatorsBalance)
			})

		this.app.ports.oscillator1DetunePort
			.subscribe((oscillatorDetune : number) => {
				this.audioEngine.setOscillator1Detune(oscillatorDetune)
			})

		this.app.ports.oscillator2DetunePort
			.subscribe((oscillatorDetune : number) => {
				this.audioEngine.setOscillator2Detune(oscillatorDetune)
			})

		window.onblur = () => {
			console.log('BLURRRRRRR')
			this.audioEngine.panic()
		}
	}

	onMIDIFailure (e : Error) {
		console.log(`No access to MIDI devices or your browser doesn\'t \
			support WebMIDI API. Please use WebMIDIAPIShim ${e}`)
	}

}
