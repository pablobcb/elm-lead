import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import {ADSR, ADSRState} from './ADSR'

export interface FilterState {
	type_: string
	frequency: number
	q: number
	envelopeAmount: number
	adsr: ADSRState
}

export class Filter {
	public context: AudioContext
	public inputs = [] as Array<GainNode>
	public outputs = [] as Array<GainNode>
	public biquadFilters = [] as Array<BiquadFilterNode>
	public adsr: ADSR
	public envelopeAmount: number

	constructor(context: AudioContext) {
		this.context = context

		/* filter adsr */
		this.adsr = new ADSR(this.context)

		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			/* AudioNode graph routing */
			this.inputs[i] = this.context.createGain()
			this.outputs[i] = this.context.createGain()
			this.biquadFilters[i] = this.context.createBiquadFilter()
			this.inputs[i].connect(this.biquadFilters[i])
			this.biquadFilters[i].connect(this.outputs[i])
		}
	}

	/* triggers filter's attack, decay, and sustain envelope  */
	public noteOn = (midiNote: number) => {
		const filterMinFreq = this.biquadFilters[midiNote].frequency.value
		let filterMaxFreq =
			this.envelopeAmount * MIDI.toFilterCutoffFrequency(127)

		if (filterMaxFreq < filterMinFreq) {
			filterMaxFreq = filterMinFreq
		}

		const filterMaxInCents = 1200 * Math.log2(filterMaxFreq / filterMinFreq)

		this.adsr.on(0, filterMaxInCents)(this.biquadFilters[midiNote].detune)
	}

	/* triggers filter's release envelope  */
	public noteOff = (midiNote: number) => {
		this.adsr.off(this.biquadFilters[midiNote].detune)
	}

	public setCutoff = (midiValue: number) => {
		this.biquadFilters.forEach(filter => {
			filter.frequency.value =
				MIDI.toFilterCutoffFrequency(midiValue)
		})
	}

	public setQ = (midiValue: number) => {
		this.biquadFilters.forEach(filter => {
			filter.Q.value = MIDI.toFilterQAmount(midiValue)
		})
	}

	public setType = (filterType: string) => {
		if (CONSTANTS.FILTER_TYPES.indexOf(filterType) !== -1) {
			this.biquadFilters.forEach(filter => {
				filter.type = filterType
			})
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

	public connect = (node: AudioParam) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.outputs[i].connect(node)
		}
	}

	public disconnect = (node: AudioParam) => {
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			this.outputs[i].disconnect(node)
		}
	}

}
