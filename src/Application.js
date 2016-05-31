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
			let midiEvent = new Event("midimessage")
			midiEvent.data = midiData
			this.audioEngine.onMIDIMessage(midiEvent)
		})
	}

	onMIDIFailure (e : Error) {
		console.log(`No access to MIDI devices or your browser doesn\'t \
			support WebMIDI API. Please use WebMIDIAPIShim ${e}`)
	}

}
