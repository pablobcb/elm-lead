import Elm from './Main.elm'

import AudioEngine from './AudioEngine'

export default class Application {

	constructor() {
		this.app = Elm.Main.fullscreen()

		if (navigator.requestMIDIAccess) {
			navigator.requestMIDIAccess()
				.then(::this.onMIDISuccess, this.onMIDIFailure)
		} else {
			alert('No MIDI support in your browser.')
		}
	}

	onMIDISuccess (midiAccess) {
		this.audioEngine = new AudioEngine(midiAccess)

		this.app.ports.noteOn.subscribe(midiNote =>
			this.audioEngine.noteOn(midiNote.note, midiNote.velocity)
		)

	}

	onMIDIFailure (e) {
		console.log(`No access to MIDI devices or your browser doesn\'t \
			support WebMIDI API. Please use WebMIDIAPIShim ${e}`)
	}

}
