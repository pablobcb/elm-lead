import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import ADSR from './ADSR'


export default class Filter {
	constructor (context, state) {
		this.context = context

		/* filter state */
		this.biquadFilter = this.context.createBiquadFilter()
		this.biquadFilter.type = state.type_
		this.biquadFilter.frequency.value = state.frequency
		this.biquadFilter.Q.value = state.q
		this.envelopeAmount = state.envelopeAmount

		/* adsr state */
		this.adsr = new ADSR(this.context, state.amp)

		/* AudioNode graph routing */
		this.input = this.context.createGain()
		this.output = this.context.createGain()
		this.input.connect(this.biquadFilter)
		this.biquadFilter.connect(this.output)
	}

	_ = () => { }

	/* triggers filter's attack, decay, and sustain envelope  */
	noteOn = () => {
		const filterMinFreq = this.biquadFilter.frequency.value
		let filterMaxFreq =
			this.envelopeAmount * MIDI.toFilterCutoffFrequency(127)

		if (filterMaxFreq < filterMinFreq) {
			filterMaxFreq = filterMinFreq
		}

		const filterMaxInCents = 1200 * Math.log2(filterMaxFreq / filterMinFreq)

		this.adsr.on(0, filterMaxInCents)(this.biquadFilter.detune)
	}

	/* triggers filter's release envelope  */
	noteOff = () => {
		this.adsr.off(this.biquadFilter.detune)
	}

	get type () {
		return this.biquadFilter.type
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
		this.biquadFilter.frequency.value =
			MIDI.toFilterCutoffFrequency(midiValue)
	}

	setQ = midiValue => {
		this.biquadFilter.Q.value = MIDI.toFilterQAmount(midiValue)
	}

	setType = filterType => {
		if (CONSTANTS.FILTER_TYPES.includes(filterType.toLowerCase())) {
			this.biquadFilter.type = filterType.toLowerCase()
		} else {
			throw new Error('Invalid Filter Type')
		}
	}

	setEnvelopeAmount = midiValue => {
		this.envelopeAmount = MIDI.logScaleToMax(midiValue, 1)
	}

}
