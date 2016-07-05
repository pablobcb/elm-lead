import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import ADSR from './ADSR'


export default class Filter {
	constructor (context, state) {
		this.context = context
		this.input = this.context.createGain()
		this.output = this.context.createGain()
		this.filter = this.context.createBiquadFilter()

		this.filter.type = state.type_
		this.filter.frequency.value = state.frequency
		this.filter.Q.value = state.q

		this.adsr = new ADSR(this.context, state.amp)
		this.envelopeAmount = state.envelopeAmount

		this.input.connect(this.filter)
		this.filter.connect(this.output)
	}

	_ = () => {}

	noteOn = (midiNote) => {
		const filterMinAmmount = this.filter.frequency.value
		const filterMaxAmmount = this.envelopeAmount *
			(CONSTANTS.MAX_FILTER_FREQUENCY - CONSTANTS.MIN_FILTER_FREQUENCY) +
			CONSTANTS.MIN_FILTER_FREQUENCY

		this.adsr.on(filterMinAmmount, filterMaxAmmount)(this.filter.detune)
	}

	noteOff = (midiNote) => {
		this.adsr.off(this.filter.detune)
	}

	get type () {
		return this.filter.type
	}

	connect = node => {
		this.output.connect(node)
		return this
	}

	disconnect = node => {
		this.output.disconnect(node)
		return this
	}

	setCutoff = midiValue => {
		this.filter.frequency.value = MIDI.toFilterCutoffFrequency(midiValue)
	}

	setQ = midiValue => {
		this.filter.Q.value = MIDI.toFilterQAmount(midiValue)
	}

	setType = filterType => {
		if(CONSTANTS.FILTER_TYPES.includes(filterType.toLowerCase())) {
			this.filter.type = filterType.toLowerCase()
		}
		else{
			throw new Error('Invalid Filter Type')
		}
	}

	setEnvelopeAmount = midiValue => {
		this.envelopeAmount = MIDI.logScaleToMax(midiValue,	1)
	}

}