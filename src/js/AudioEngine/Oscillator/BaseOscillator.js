export default class BaseOscillator {

	constructor (context) {
		this.context = context
		this.output = this.context.createGain()
		this.output.gain.value = .5
		this.voices = {}
		this.voiceGains = []
		this.frequencyGains = []
		this.kbdTrack = true


		for (let i = 0; i <128; i++) {
			//TODO: create FM osc and let it holdd the gains,
			// instead of the modular like it is
			this.frequencyGains[i] = this.context.createGain()
			this.voiceGains[i] = this.context.createGain()
			this.voiceGains[i].connect(this.output)
		}
	}

	panic =	() => {
		for (const midiNote in this.voices) {
			if (this.voices.hasOwnProperty(midiNote)) {
				this.voices[midiNote].stop()
			}
		}
	}

	frequencyFromNoteNumber = (note) => {
		const note_ = this.kbdTrack ? note : 60
		return 440 * Math.pow(2, (note_ - 69) / 12)
	}

	noteOn = (midiNote, noteOnAmpCB) => {
		const midiNoteKey = midiNote.toString()
		const now = this.context.currentTime

		if (midiNoteKey in this.voices) {
			this.voices[midiNoteKey]
				.stop(now)
			this.frequencyGains[midiNote].disconnect()
			this.voices[midiNoteKey].disconnect()

			delete this.voices[midiNoteKey]
		}

		this._noteOn(midiNote)
		this.voices[midiNoteKey].onended = () => {
			this._onended(this.voices[midiNoteKey])
			this.voices[midiNoteKey].disconnect()
			delete this.voices[midiNoteKey]
		}
		this.voices[midiNoteKey].start(now)

		if (noteOnAmpCB) {
			noteOnAmpCB(this.voiceGains[midiNote].gain)
		}
	}

	noteOff = (midiNote, noteOffAmpCB) => {
		const midiNoteKey = midiNote.toString()
		const osc = this.voices[midiNoteKey]

		if (!osc) {
			return
		}

		const voiceGain = this.voiceGains[midiNote].gain
		const releaseTime = noteOffAmpCB(voiceGain)

		osc.stop(releaseTime)
	}

	setSemitone = () => {}

	setDetune = () => {}

	setPulseWidth = () => {}

	setWaveform = () => {}

	setKbdTrack = (state) => {
		this.kbdTrack = state
	}

	_onended = () => {}

	connect = function (node) {
		this.output.connect(node)
		return this
	}

	disconnect = function (node) {
		this.output.disconnect(node)
		return this
	}
}
