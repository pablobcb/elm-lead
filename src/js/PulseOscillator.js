
const pulseCurve = new Float32Array(256)
for(let i=0;i<128;i++) {
	pulseCurve[i] = -1
	pulseCurve[i+128] =1
}

const constantOneCurve = new Float32Array(2)
constantOneCurve[0]=1
constantOneCurve[1]=1


export default class PulseOscillator {
	constructor (context) {
		this.context = context
		this.output = this.context.createGain()
		this.output.gain.value = 1
		this.oscillators = {}
		this.type = 'pulse'
		this.detune = 0
		this.semitone = 0
		this.pulseWidth = 0
		this.fmGain = 0
		this.frequencyGains = [] //this.context.createGain()
		this.oscillatorGains = []

		for(let i=0; i<128; i++) {
			this.frequencyGains[i] = this.context.createGain()
			this.oscillatorGains[i] = this.context.createGain()
		}
	}

	frequencyFromNoteNumber = (note) => {
		return 440 * Math.pow(2, (note - 69) / 12)
	}

	panic =	() => {
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].stop()
			}
		}
	}


	setDetune = (detune) => {
		this.detune = detune
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].detune.value =
					detune + this.semitone
			}
		}
	}

	setSemitone = (semitone) => {
		this.semitone = semitone * 100
		for(const midiNote in this.oscillators) {
			if(this.oscillators.hasOwnProperty(midiNote)) {
				this.oscillators[midiNote].detune.value =
					this.detune + this.semitone
			}
		}
	}

	setPulseWidth = (pulseWidth) => {
		this.pulseWidth = pulseWidth
		if(this.type == CONSTANTS.WAVEFORM_TYPE.SQUARE) {
			for(const midiNote in this.oscillators) {
				if(this.oscillators.hasOwnProperty(midiNote)) {
					this.oscillators[midiNote].setWidth(this.pulseWidth)
				}
			}
		}
	}

	setFMGain = (fmGain) => {
		this.fmGain = fmGain
		for(let i=0; i<128; i++) {
			this.frequencyGains[i].gain.value = this.fmGain
			console.log(this.fmGain)
		}
	}

	noteOn = (midiNote) => {
		const midiNoteKey = midiNote.toString()

		debugger
		if(midiNoteKey in this.oscillators){
			return
		}

		this.sawNode = this.context.createOscillator()
		this.sawNode.type = 'sawtooth'
		this.pulseShaper = this.context.createWaveShaper()
		this.pulseShaper.curve = pulseCurve
		this.sawNode.connect(this.pulseShaper)
		
		const widthGain = this.context.createGain()
		widthGain.gain.value = 0
		this.sawNode.width = widthGain.gain
		
		widthGain.connect(this.pulseShaper)
		
		this.constantOneShaper = this.context.createWaveShaper()
		this.constantOneShaper.curve = constantOneCurve
		this.sawNode.connect(this.constantOneShaper)
		this.constantOneShaper.connect(widthGain)
	


		this.sawNode.frequency.value = this.frequencyFromNoteNumber(midiNote)
		this.sawNode.detune.value = this.detune + this.semitone
		
		this.sawNode.onended = () => {			
			this.pulseShaper.disconnect(this.oscillatorGains[midiNote])
			this.frequencyGains[midiNote].disconnect(this.sawNode.frequency)
			delete this.oscillators[midiNoteKey]
		}


		this.pulseShaper.connect(this.oscillatorGains[midiNote])
		
		this.frequencyGains[midiNote].connect(this.sawNode.frequency)


		this.pulseShaper.connect(this.output)
		this.sawNode.start(this.context.currentTime)
		this.oscillators[midiNoteKey] = this.sawNode
	}


	noteOff = (at, midiNote) => {
		let midiNoteKey
		
		if(midiNote)
			midiNoteKey = midiNote.toString()
		
			
		if(!(midiNoteKey in this.oscillators))
			return

		this.oscillators[midiNoteKey].stop(at)

	}

	setWidth = (width) => {
		this.sawNode.width.value = width
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


