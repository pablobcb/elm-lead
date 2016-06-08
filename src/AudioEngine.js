// @flow

export default class AudioEngine {

	context : AudioContext;

	oscillators : Array<Object>;

	constructor (midiAccess : MIDIAccess) {
		this.context = new AudioContext
		this.oscillators = []
		
		this.initializeMidiAccess(midiAccess)
		
		this.initializeMasterVolume()
		
		this.initializeOscillatorsGain ()
		
		this.oscillator2Semitone = 0
		this.oscillator2Detune = 0
		this.fmAmount = 0
	}

	initializeMidiAccess (midiAccess : MIDIAccess) {
		// loop over all available inputs and listen for any MIDI input
		for (const input of midiAccess.inputs.values()) {
			input.onmidimessage = this.onMIDIMessage.bind(this)
		}
	}

	initializeMasterVolume () {
		this.masterVolume = this.context.createGain()
		this.masterVolume.gain.value = 0.1
		this.masterVolume.connect(this.context.destination)
	}

	initializeOscillatorsGain () {
		this.oscillator1Gain = this.context.createGain()
		this.oscillator1Gain.gain.value = 1
		this.oscillator1Gain.connect(this.masterVolume)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = 1
		this.oscillator2Gain.connect(this.masterVolume)
	}

	onMIDIMessage (event : Event) {
		const data = event.data
		console.log(event)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf

		// channel agnostic message type
		const type = data[0] & 0xf0

		const note = data[1]
		const velocity = data[2]

		switch (type) {
			case 144: // noteOn message
				this.noteOn(note, velocity)
				break
			case 128: // noteOff message
				this.noteOff(note, velocity)
				break
		}
	}

	frequencyFromNoteNumber (note : number) : number {
		return 440 * Math.pow(2, (note - 69) / 12)
	}

	balanceToGains (balance : number) : Array<number> {
		let osc1Gain = 1
		let osc2Gain = 1
		const gainPercentage = Math.abs(balance) / 100

		if(balance < 0)
			osc1Gain -= gainPercentage
		else if(balance > 0)
			osc2Gain -= gainPercentage

		return [osc1Gain, osc2Gain]
	}

	noteOn (midiNote : number, velocity : number) {
		//if(this.oscillators[midiNote])
			//return

		const osc1 = this.context.createOscillator()
		const osc2 = this.context.createOscillator()

		osc1.type = 'sawtooth'
		osc1.frequency.value = this.frequencyFromNoteNumber(midiNote)


		osc2.type = 'sawtooth'
		osc2.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc2.detune.value = this.oscillator2Detune + this.oscillator2Semitone

		osc2.connect(this.oscillator2Gain)

		this.modGain = this.context.createGain()
		this.modGain.gain.value = this.fmAmount

		osc2.connect(this.modGain)

		this.modGain.connect(osc1.frequency)

		osc1.connect(this.oscillator1Gain)

		osc1.start(this.context.currentTime)
		osc2.start(this.context.currentTime)

		this.oscillators[midiNote] = [osc1, osc2]
	}

	noteOff (midiNote : number, velocity : number) {
		if(!this.oscillators[midiNote])
			return

		this.oscillators[midiNote].forEach(oscillator => {
			oscillator.stop(this.context.currentTime)
			oscillator = null
		})

		
	}

	panic () {
		this.oscillators.forEach(oscillator => {
			if(oscillator){
				oscillator.forEach(osc => {
					osc.stop(this.context.currentTime)
					osc = null
				})
				oscillator = null
			}
		})

		this.oscillators = []
	}

	setMasterVolumeGain (masterVolumeGain : number) {
		this.masterVolume.gain.value = masterVolumeGain / 100
	}

	setOscillatorsBalance (oscillatorsBalance : number) {
		const gainPercentage = Math.abs(oscillatorsBalance) / 100

		this.oscillator1Gain.gain.value = 1
		this.oscillator2Gain.gain.value = 1

		if(oscillatorsBalance > 0)
			this.oscillator1Gain.gain.value -= gainPercentage
		else if(oscillatorsBalance < 0)
			this.oscillator2Gain.gain.value -= gainPercentage
	}

	setOscillator2Semitone (oscillatorSemitone : number) {
		this.oscillator2Semitone = oscillatorSemitone * 100
		this.oscillators.forEach(oscillator => {
			if(oscillator)
				oscillator[1].detune.value = this.oscillator2Detune + this.oscillator2Semitone
		})
	}

	setOscillator2Detune (oscillatorDetune : number) {
		this.oscillator2Detune = oscillatorDetune
		this.oscillators.forEach(oscillator => {
			if(oscillator)
				oscillator[1].detune.value = this.oscillator2Detune + this.oscillator2Semitone
		})
	}

	setSetFmAmount (fmAmount : number) {
		this.fmAmount = fmAmount * 10
		this.oscillators.forEach(oscillator => {
			if(oscillator)
				this.modGain.gain.value = this.fmAmount
		})
	}

}
