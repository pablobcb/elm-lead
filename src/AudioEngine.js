import Elm from './Main.elm'

export default class AudioEngine {

	constructor () {
		if (navigator.requestMIDIAccess) {
			navigator.requestMIDIAccess({
				sysex: false
				// this defaults to 'false' and we won't be covering sysex in
				// this article.
			}).then(onMIDISuccess, onMIDIFailure)
		} else {
			alert('No MIDI support in your browser.')
		}

		// midi functions
		function onMIDISuccess(midiAccess) {
			// when we get a succesful response, run this code
			let inputs = midiAccess.inputs.values()

			// iterate through the devices
			let input = inputs.next()
			for (; input && !input.done; input = inputs.next()) {
				console.log(input.value)
			}

			// this is our raw MIDI data, inputs, outputs, and sysex status
			const midi = midiAccess

			inputs = midi.inputs.values()
			// loop over all available inputs and listen for any MIDI input
			input = inputs.next()
			for (; input && !input.done; input = inputs.next()) {
				// each time there is a midi message call the onMIDIMessage
				// function
				input.value.onmidimessage = onMIDIMessage
			}
		}

		function onMIDIMessage(event) {
			const data = event.data
			// var cmd = data[0] >> 4
			// var channel = data[0] & 0xf

			// channel agnostic message type. Thanks, Phil Burk.
			const type = data[0] & 0xf0

			const note = data[1]
			const velocity = data[2]

			switch (type) {
				case 144: // noteOn message
					noteOn(note, velocity)
					break
				case 128: // noteOff message
					noteOff(note, velocity)
					break
			}

			// logger("breno", 'key data', data);
		}

		const oscillators = []

		function noteOn(midiNote) {
			const osc1 = context.createOscillator()
			oscillators[midiNote] = [osc1]

			osc1.frequency.value = frequencyFromNoteNumber(midiNote)
			osc1.type = 'sine'
			osc1.connect(masterVolume)
			osc1.start(context.currentTime)
		}

		function noteOff(midiNote, velocity) {
			console.log(midiNote, velocity)
		}

		function onMIDIFailure(e) {
			console.log(`No access to MIDI devices or your browser doesn\'t \
				support WebMIDI API. Please use WebMIDIAPIShim ${e}`)
		}

		// utility functions

		function frequencyFromNoteNumber(note) {
			return 440 * Math.pow(2, (note - 69) / 12)
		}

		// function logger(container, label, data) {
		// 	const messages = label + ' [channel: ' + (data[0] & 0xf) +
		// 		', cmd: ' +
		// 		(data[0] >> 4) + ', type: ' + (data[0] & 0xf0) + ' , note: ' +
		// 		data[1] + ' , velocity: ' + data[2] + ']'

		// 	console.log(messages)
		// }

		const app = Elm.Main.fullscreen()

		const context = new AudioContext

		const masterVolume = context.createGain()

		masterVolume.gain.value = 0.2

		masterVolume.connect(context.destination)

		app.ports.noteOn.subscribe(midiNote =>
			noteOn(midiNote.note, midiNote.velocity)
		)

	}

}
