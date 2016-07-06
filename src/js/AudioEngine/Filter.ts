import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import ADSR from './ADSR'


export default class Filter {

	public context : AudioContext
	public input : GainNode
	public output : GainNode
	public filter : BiquadFilterNode
	public adsr : ADSR
	public envelopeAmount : number

	constructor (context: AudioContext, state: any) {
		this.context = context

		this.biquadFilter = this.context.createBiquadFilter()

		/* AudioNode graph routing */
		this.input = this.context.createGain()
		this.output = this.context.createGain()
		this.input.connect(this.biquadFilter)
		this.biquadFilter.connect(this.output)
		this.adsr = new ADSR(this.context, state.adsr)

		this._setState(state)
	}

	_ = () => { }

	_setState = state => {
		/* filter state */
		this.biquadFilter.type = state.type_
		this.biquadFilter.frequency.value = state.frequency
		this.biquadFilter.Q.value = state.q
		this.envelopeAmount = state.envelopeAmount

	}

	setState = state => {
		this._setState = state
		this.adsr.setState(state.adsr)
	}


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

	connect = (node: any) => {
		this.output.connect(node)
		return this
	}

	disconnect = (node: any) => {
		this.output.disconnect(node)
		return this
	}

	setCutoff = (midiValue: number) => {
		this.biquadFilter.frequency.value =
			MIDI.toFilterCutoffFrequency(midiValue)
	}

	setQ = (midiValue: number) => {
		this.biquadFilter.Q.value = MIDI.toFilterQAmount(midiValue)
	}

	setType = (filterType: string) => {
		if (CONSTANTS.FILTER_TYPES.includes(filterType.toLowerCase())) {
			this.biquadFilter.type = filterType.toLowerCase()
		} else {
			throw new Error('Invalid Filter Type')
		}
	}

	setEnvelopeAmount = (midiValue: number) => {
		this.envelopeAmount = MIDI.logScaleToMax(midiValue, 1)
	}

}
