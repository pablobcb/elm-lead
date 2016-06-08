// @flow

export default class AudioEngine {
	constructor (midiAccess : MIDIAccess) {
		this.context = new AudioContext
		this.oscillators = {}
		
		this.initializeMidiAccess(midiAccess)
		
		this.initializeMasterVolume()
		
		this.initializeOscillatorsGain ()
		
		this.oscillator1Waveform = 'sawtooth'
		this.oscillator2Waveform = 'sawtooth'
		this.oscillator2Semitone = 0
		this.oscillator2Detune = 0
		
		this.initializeFMGain ()
		this.pulseWith = 0.5
	}

	createPulseOscillator = () => {
		const pulseCurve = new Float32Array(256)
		for(let i=0; i<128; i++) {
			pulseCurve[i] = -1
			pulseCurve[i + 128] = 1
		}

		const constantOneCurve = new Float32Array(2)
		constantOneCurve[0] = 1
		constantOneCurve[1] = 1

		const node = this.context.createOscillator()
		node.type = 'sawtooth'

		const pulseShaper = this.context.createWaveShaper()
		pulseShaper.curve = pulseCurve
		node.connect(pulseShaper)

		const widthGain = this.context.createGain()
		widthGain.gain.value = 0
		node.width = widthGain.gain 
		widthGain.connect(pulseShaper)

		const constantOneShaper = this.context.createWaveShaper()
		constantOneShaper.curve = constantOneCurve
		node.connect(constantOneShaper)
		constantOneShaper.connect(widthGain)

		node.connect=function() {
			pulseShaper.connect.apply(pulseShaper, arguments)
			return node
		}

		node.disconnect=function() {
			pulseShaper.disconnect.apply(pulseShaper, arguments)
			return node
		}

		return node
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
		this.oscillator1Gain.gain.value = .5
		this.oscillator1Gain.connect(this.masterVolume)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = .5
		this.oscillator2Gain.connect(this.masterVolume)
	}

	initializeFMGain () {
		this.fmGain = this.context.createGain();
		this.fmGain.gain.value = 0
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

	noteOn (midiNote : number, velocity : number) {
		//if(this.oscillators[midiNote])
			//return
		const osc1 = this.oscillator1Waveform == 'square' ? 
			this.createPulseOscillator() : this.context.createOscillator() 
		const osc2 = this.context.createOscillator()

		if(this.oscillator1Waveform == 'square')
			osc1.width.value = this.pulseWith

		// OSC1
		osc1.type = this.oscillator1Waveform
		osc1.frequency.value = this.frequencyFromNoteNumber(midiNote)

		osc1.connect(this.oscillator1Gain)

		// OSC2
		osc2.type = this.oscillator2Waveform
		osc2.frequency.value = this.frequencyFromNoteNumber(midiNote)
		osc2.detune.value = this.oscillator2Detune + this.oscillator2Semitone

		osc2.connect(this.oscillator2Gain)

		// FM
		osc2.connect(this.fmGain)
		this.fmGain.connect(osc1.frequency)

		osc1.start(this.context.currentTime)
		osc2.start(this.context.currentTime)

		this.oscillators[midiNote.toString()] = [osc1, osc2]
	}

	noteOff (midiNote : number, velocity : number) {
		if(!this.oscillators[midiNote])
			return

		let oscillator = this.oscillators[midiNote]

		oscillator[0].stop(this.context.currentTime)
		oscillator[1].stop(this.context.currentTime)

		this.fmGain.disconnect(oscillator[0].frequency)
		oscillator[0].disconnect(this.oscillator1Gain)
		//oscillator[0] = null

		oscillator[1].disconnect(this.fmGain)
		oscillator[1].disconnect(this.oscillator2Gain)
		//oscillator[1] = null

		delete this.oscillators[midiNote]

		//this.oscillators[midiNote].forEach(oscillator => {
//
		//})		
	}

	panic () {
		for(let midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote][0].stop(this.context.currentTime)
				this.oscillators[midiNote][1].stop(this.context.currentTime)
			}
			delete this.oscillators[midiNote]
		}
	}

	setMasterVolumeGain (masterVolumeGain : number) {
		this.masterVolume.gain.value = masterVolumeGain / 100
	}

	setOscillatorsBalance (oscillatorsBalance : number) {
		const gainPercentage = Math.abs(oscillatorsBalance) / 100

		this.oscillator1Gain.gain.value = .5
		this.oscillator2Gain.gain.value = .5

		if(oscillatorsBalance > 0) {
			this.oscillator1Gain.gain.value -= gainPercentage
			this.oscillator2Gain.gain.value += gainPercentage
		}
		else if(oscillatorsBalance < 0) {
			this.oscillator1Gain.gain.value += gainPercentage
			this.oscillator2Gain.gain.value -= gainPercentage
		}
	}

	setOscillator2Semitone (oscillatorSemitone : number) {
		this.oscillator2Semitone = oscillatorSemitone * 100
		for(let midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote][1].detune.value = 
					this.oscillator2Detune + this.oscillator2Semitone
			}
		}
	}

	setOscillator2Detune (oscillatorDetune : number) {
		this.oscillator2Detune = oscillatorDetune
		for(let midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote][1].detune.value = 
					this.oscillator2Detune + this.oscillator2Semitone
			}
		}
	}

	setFmAmount (fmAmount : number) {
		this.fmGain.gain.value = fmAmount / 100 // * 10
	}

	setPulseWidth (pulseWith : number) {
		this.pulseWith = pulseWith / 100
		/*this.oscillators.forEach(oscillator => {
			if(oscillator) {
				if(oscillator[0].type == 'square')
					oscillator[0].width = this.pulseWith
			}
		})*/
	}

	setOscillator1Waveform (waveform_) {
		const validWaveforms = ['sine', 'triangle', 'sawtooth', 'square']
		const waveform = waveform_.toLowerCase()
		const lastWaveform = this.oscillator1Waveform

		if(validWaveforms.indexOf(waveform) == -1)
			throw new Error('Invalid Waveform Type')

		this.oscillator1Waveform = waveform
		//this.oscillator1Waveform = waveform.toLowerCase()
		for(let midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				/*if(lastWaveform == 'square') {
					console.log("ERA SQUARE")
					
					const osc1 = this.context.createOscillator()
					osc1.type = this.oscillator1Waveform
					osc1.frequency.value = oscillator[0].frequency.value
					
					this.modGain.disconnect(oscillator[0].frequency)
					this.modGain.connect(osc1.frequency)

					oscillator[0].disconnect(this.oscillator1Gain)
					osc1.connect(this.oscillator1Gain)

					osc1.start(this.context.currentTime)

					oscillator[0] = osc1
				}*/

				//console.log("VIROU " + this.oscillator1Waveform)
				this.oscillators[midiNote][0].type = this.oscillator1Waveform

				/*if(waveform == 'square') {
					console.log("VIROU SQUARE")
					const pulseOsc = this.createPulseOscillator()
					pulseOsc.frequency.value = oscillator[0].frequency.value
					pulseOsc.type = waveform
					pulseOsc.width = this.pulseWith

					this.modGain.disconnect(oscillator[0].frequency)
					this.modGain.connect(pulseOsc.frequency)

					oscillator[0].disconnect(this.oscillator1Gain)
					pulseOsc.connect(this.oscillator1Gain)

					pulseOsc.start(this.context.currentTime)

					oscillator[0] = pulseOsc
				}*/
			}
		}
	}

	setOscillator2Waveform (waveform) {
		const validWaveforms = ['triangle', 'sawtooth', 'square']

		if(validWaveforms.indexOf(waveform.toLowerCase()) == -1)
			throw new Error('Invalid Waveform Type')

		this.oscillator2Waveform = waveform.toLowerCase()
		/*this.oscillators.forEach(oscillator => {
			if(oscillator)
				oscillator[1].type = this.oscillator2Waveform
		})*/
	}
}
