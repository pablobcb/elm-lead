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

	noteOn = () => {
		const filterMinFreq = this.filter.frequency.value
		let filterMaxFreq =
			this.envelopeAmount * MIDI.toFilterCutoffFrequency(127)

		if (filterMaxFreq < filterMinFreq) {
			filterMaxFreq = filterMinFreq
		}

		const filterMaxInCents = 1200 * Math.log2(filterMaxFreq / filterMinFreq)

		this.adsr.on(0, filterMaxInCents)(this.filter.detune)
	}

	noteOff = () => {
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
		const value = MIDI.toFilterCutoffFrequency(midiValue)
		// const now = this.context.currentTime

		//this.filter.detune.cancelScheduledValues(now)
		this.filter.frequency.value = value

		//debugger
	}

	setQ = midiValue => {
		this.filter.Q.value = MIDI.toFilterQAmount(midiValue)
	}

	setType = filterType => {
		if (CONSTANTS.FILTER_TYPES.includes(filterType.toLowerCase())) {
			this.filter.type = filterType.toLowerCase()
		} else {
			throw new Error('Invalid Filter Type')
		}
	}

	setEnvelopeAmount = midiValue => {
		this.envelopeAmount = MIDI.logScaleToMax(midiValue, 1)
	}

}
