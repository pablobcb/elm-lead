// @flow

export default class AudioEngine {
	constructor () {
		this.context = new AudioContext

		this.initializeMasterVolume()

		this.initializeOscillators ()

		this.initializeOscillatorsGain ()

		this.initializeFMGain ()
	}

	createPulseOscillator () {
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

		node.setWidth = function (width) {
			node.width.value = width
		}

		node.connect = function () {
			pulseShaper.connect.apply(pulseShaper, arguments)
			return node
		}

		node.disconnect = function () {
			pulseShaper.disconnect.apply(pulseShaper, arguments)
			return node
		}

		return node
	}

	createOscillatorNode () {
		const that = this
		const node = that.context.createGain()
		node.gain.value = 1
		node.oscillators = {}
		node.type = 'sawtooth'
		node.detune = 0
		node.semitone = 0
		node.pulseWidth = 0
		node.fmGain = 0
		node.frequency = {} //that.context.createGain()

		node.frequencyFromNoteNumber = function (note) {
			return 440 * Math.pow(2, (note - 69) / 12)
		}

		node.panic = function () {
			for(const midiNote in node.oscillators) {
				if(node.oscillators.hasOwnProperty(midiNote)) {
					node.noteOff(Number(midiNote))
				}
			}
		}

		node.noteOff = function (midiNote) {
			const midiNoteKey = midiNote.toString()

			if(!(midiNoteKey in node.oscillators))
				return

			node.oscillators[midiNoteKey].stop(that.context.currentTime)

			// FM
			node.frequency[midiNoteKey]
				.disconnect(node.oscillators[midiNoteKey].frequency)

			delete node.frequency[midiNoteKey]

			// OSC
			node.oscillators[midiNoteKey].disconnect(node)
			delete node.oscillators[midiNoteKey]
		}

		node.noteOn = function (midiNote) {
			const midiNoteKey = midiNote.toString()

			if(midiNoteKey in node.oscillators)
				return

			// PW
			const osc = node.type != 'square' ?
				that.context.createOscillator() :
				that.createPulseOscillator()

			if(node.type == 'square')
				osc.setWidth(node.pulseWidth)

			// OSC
			osc.type = node.type
			osc.frequency.value = node.frequencyFromNoteNumber(midiNote)
			osc.detune.value = node.detune + node.semitone

			// FM
			const fmGain = that.context.createGain()
			fmGain.gain.value = node.fmGain
			fmGain.connect(osc.frequency)
			node.frequency[midiNoteKey] = fmGain

			osc.connect(node)
			osc.start(that.context.currentTime)
			node.oscillators[midiNoteKey] = osc
		}

		node.setDetune = function (detune) {
			node.detune = detune
			for(const midiNote in node.oscillators) {
				if(node.oscillators.hasOwnProperty(midiNote)) {
					node.oscillators[midiNote].detune.value =
						node.detune + node.semitone
				}
			}
		}

		node.setSemitone = function (semitone) {
			node.semitone = semitone * 100
			for(const midiNote in node.oscillators) {
				if(node.oscillators.hasOwnProperty(midiNote)) {
					node.oscillators[midiNote].detune.value =
						node.detune + node.semitone
				}
			}
		}

		node.setWaveform = function (waveform) {
			for(const midiNote in node.oscillators) {
				if(node.oscillators.hasOwnProperty(midiNote)) {
					if(waveform == 'square' || node.type == 'square') {
						node.noteOff(Number(midiNote))
						node.type = waveform
						node.noteOn(Number(midiNote))
					}
					node.oscillators[midiNote].type = waveform
				}
			}
			node.type = waveform
		}

		node.setPulseWidth = function (pulseWidth) {
			node.pulseWidth = pulseWidth
			if(node.type == 'square') {
				for(const midiNote in node.oscillators) {
					if(node.oscillators.hasOwnProperty(midiNote)) {
						node.oscillators[midiNote].setWidth(node.pulseWidth)
					}
				}
			}
		}

		node.setFMGain = function (fmGain) {
			node.fmGain = fmGain
			for(const midiNote in node.frequency) {
				if(node.oscillators.hasOwnProperty(midiNote)) {
					node.frequency[midiNote].gain.value = node.fmGain
					console.log(node.fmGain)
				}
			}
		}

		return node
	}

	initializeMasterVolume () {
		this.masterVolume = this.context.createGain()
		this.masterVolume.gain.value = 0.1
		this.masterVolume.connect(this.context.destination)
	}

	initializeOscillators () {
		this.oscillator1 = this.createOscillatorNode()
		this.oscillator2 = this.createOscillatorNode()
	}

	initializeOscillatorsGain () {
		this.oscillator1Gain = this.context.createGain()
		this.oscillator1Gain.gain.value = .5
		this.oscillator1Gain.connect(this.masterVolume)
		this.oscillator1.connect(this.oscillator1Gain)

		this.oscillator2Gain = this.context.createGain()
		this.oscillator2Gain.gain.value = .5
		this.oscillator2Gain.connect(this.masterVolume)
		this.oscillator2.connect(this.oscillator2Gain)
	}

	initializeFMGain () {
		//this.fmGain = this.context.createGain()
		//this.fmGain.gain.value = 0
		/*this.oscillator2.connect(this.fmGain)
		this.fmGain.connect(this.oscillator1.frequency)*/
	}

	onMIDIMessage (data) {
		//console.log(data)
		// var cmd = data[0] >> 4
		// var channel = data[0] & 0xf

		// channel agnostic message type
		const type = data[0] & 0xf0
		const note = data[1]
		const velocity = data[2]

		switch (type) {
			case 144:
				this.noteOn(note, velocity)
				break
			case 128:
				this.noteOff(note, velocity)
				break
		}
	}

	noteOn (midiNote, velocity) {
		this.oscillator1.noteOn(midiNote)
		this.oscillator2.noteOn(midiNote)

		console.log(this.oscillator2.oscillators)
		console.log(this.oscillator1.frequency)
		this.oscillator2.oscillators[midiNote.toString()]
			.connect(this.oscillator1.frequency[midiNote.toString()])
	}

	noteOff (midiNote, velocity) {
		console.log(this.oscillator2.oscillators)
		console.log(this.oscillator1.frequency)
		this.oscillator2.oscillators[midiNote.toString()]
			.disconnect(this.oscillator1.frequency[midiNote.toString()])

		this.oscillator1.noteOff(midiNote)
		this.oscillator2.noteOff(midiNote)
	}

	panic () {
		this.oscillator1.panic()
		this.oscillator2.panic()
	}

	setMasterVolumeGain (masterVolumeGain) {
		this.masterVolume.gain.value = masterVolumeGain / 100
	}

	setOscillatorsBalance (oscillatorsBalance) {
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

	setOscillator2Semitone (oscillatorSemitone) {
		this.oscillator2.setSemitone(oscillatorSemitone)
	}

	setOscillator2Detune (oscillatorDetune) {
		this.oscillator2.setDetune(oscillatorDetune)
	}

	setFmAmount (fmAmount) {
		this.oscillator1.setFMGain(fmAmount * 10)
	}

	setPulseWidth (pulseWith) {
		this.oscillator1.setPulseWidth(pulseWith / 100)
		this.oscillator2.setPulseWidth(pulseWith / 100)
	}

	setOscillator1Waveform (waveform) {
		const validWaveforms = ['sine', 'triangle', 'sawtooth', 'square']
		const waveform_ = waveform.toLowerCase()

		if(validWaveforms.indexOf(waveform_) == -1)
			throw new Error('Invalid Waveform Type')

		this.oscillator1.setWaveform(waveform_)
	}

	setOscillator2Waveform (waveform) {
		const validWaveforms = ['triangle', 'sawtooth', 'square']
		const waveform_ = waveform.toLowerCase()

		if(validWaveforms.indexOf(waveform_) == -1)
			throw new Error('Invalid Waveform Type')

		this.oscillator2.setWaveform(waveform_)
	}
}
