import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import {ADSR, ADSRState} from './ADSR'

type FilterType = string

export interface FilterState {
	type_ : string
	frequency: number
	q: number
	envelopeAmount: number
	adsr: ADSRState
}

export class Filter {
	public context : AudioContext
	public input : GainNode
	public output : GainNode
	public biquadFilter : BiquadFilterNode
	public adsr : ADSR
	public envelopeAmount : number

	constructor (context: AudioContext) {
		this.context = context

		/* filter adsr */
		this.adsr = new ADSR(this.context)

		/* AudioNode graph routing */
		this.input = this.context.createGain()
		this.output = this.context.createGain()
		this.biquadFilter = this.context.createBiquadFilter()
		this.input.connect(this.biquadFilter)
		this.biquadFilter.connect(this.output)
	}

	/* triggers filter's attack, decay, and sustain envelope  */
	public noteOn = () => {
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
	public noteOff = () => {
		this.adsr.off(this.biquadFilter.detune)
	}

	public setCutoff = (midiValue: number) => {
		this.biquadFilter.frequency.value =
			MIDI.toFilterCutoffFrequency(midiValue)
	}

	public setQ = (midiValue: number) => {
		this.biquadFilter.Q.value = MIDI.toFilterQAmount(midiValue)
	}

	public setType = (filterType: string) => {
		const ft = filterType.toLowerCase()
		if (CONSTANTS.FILTER_TYPES.indexOf(ft) !== -1) {
			this.biquadFilter.type = ft
		} else {
			throw new Error('Invalid Filter Type')
		}
	}

	public setEnvelopeAmount = (midiValue: number) => {
		this.envelopeAmount = MIDI.logScaleToMax(midiValue, 1)
	}

	public setState = (state: FilterState) => {
		this.adsr.setState(state.adsr)

		this.setType(state.type_)
		this.setCutoff(state.frequency)
		this.setQ(state.q)
		this.setEnvelopeAmount(state.envelopeAmount)
	}

	public connect = (node: any) => {
		this.output.connect(node)
		return this
	}

	public disconnect = (node: any) => {
		this.output.disconnect(node)
		return this
	}

}
