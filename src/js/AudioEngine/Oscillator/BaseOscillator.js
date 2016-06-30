export default class BaseOscillator {

	constructor (context) {
		this.context = context
		this.output = this.context.createGain()
		this.output.gain.value = .5
		this.oscillators = {}
		this.oscillatorGains = []
		this.frequencyGains = []
		this.kbdTrack = true


		for(let i = 0; i <128; i++) {
			//TODO: create FM osc and let it holdd the gains,
			// instead of the modular like it is
			this.frequencyGains[i] = this.context.createGain()
			this.oscillatorGains[i] = this.context.createGain()
			this.oscillatorGains[i].connect(this.output)
		}
	}

	panic =	() => {
		for (const midiNote in this.oscillators) {
			if (this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].stop()
			}
		}
	}

	frequencyFromNoteNumber = (note) => {
		const note_ = this.kbdTrack ? note : 60
		return 440 * Math.pow(2, (note_ - 69) / 12)
	}

	noteOn = (midiNote, noteOnCB) => {
		const midiNoteKey = midiNote.toString()
		const now = this.context.currentTime

		if (midiNoteKey in this.oscillators) {
			this.oscillators[midiNoteKey]
				.stop(now)
			this.frequencyGains[midiNote].disconnect()			
			this.oscillators[midiNoteKey].disconnect()
				//.disconnect(this.oscillatorGains[midiNote])
			
			delete this.oscillators[midiNoteKey]
		} 

		this._noteOn(midiNote)
		this.oscillators[midiNoteKey].onended = () => {
			delete this.oscillators[midiNoteKey]
		}
		this.oscillators[midiNoteKey].start(now)
		
		if(noteOnCB)
			noteOnCB(this.oscillatorGains[midiNote].gain)
	}

	noteOff = (midiNote, noteOffCB) => {		
		const midiNoteKey = midiNote.toString()		
		const osc = this.oscillators[midiNoteKey]

		if(!osc) {
			return
		}

		const oscGain = this.oscillatorGains[midiNote].gain		
		const releaseTime = noteOffCB(oscGain)

		osc.stop(releaseTime)
	}

	setSemitone = () => {}

	setDetune = () => {}

	setPulseWidth = () => {}

	setWaveform = () => {}

	setKbdTrack = (state) => {
		this.kbdTrack = state
	}


	connect = function (node) {
		this.output.connect(node)
		return this
	}

	disconnect = function (node) {
		this.output.disconnect(node)
		return this
	}
}
