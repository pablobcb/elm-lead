export default class BaseOscillator {
	constructor (context) {
		this.context = context
		this.output = this.context.createGain()
		this.output.gain.value = .5
		this.oscillators = {}
		this.oscillatorGains = []
		this.frequencyGains = []

		for(let i=0; i<128; i++) {
			//TODO: create FM osc and let it holdd the gains,
			// instead of the modular like it is
			this.frequencyGains[i] = this.context.createGain()
			this.oscillatorGains[i] = this.context.createGain()
		}
	}

	panic =	() => {
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].stop()
			}
		}
	}

	frequencyFromNoteNumber = (note) => {
		return 440 * Math.pow(2, (note - 69) / 12)
	}

	noteOff = (midiNote, releaseCallback) => {
		let midiNoteKey
		
		if(midiNote)
			midiNoteKey = midiNote.toString()
		
			
		if(!(midiNoteKey in this.oscillators))
			return

		const oscGain = this.oscillatorGains[midiNote].gain
		
		const osc = this.oscillators[midiNoteKey]

		releaseCallback(oscGain)
		//osc.stop(at)
	}

	setSemitone = () => {}

	setDetune = () => {}

	setPulseWidth = () => {}

	setWaveform = () => {}

	connect = function (node) {
		this.output.connect(node)
		return this
	}

	disconnect = function (node) {
		this.output.disconnect(node)
		return this
	}
}