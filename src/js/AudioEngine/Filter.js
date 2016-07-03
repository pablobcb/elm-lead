import MIDI from '../MIDI'
import CONSTANTS from '../Constants'
import ADSR from './ADSR'


export default class Filter {
	constructor (context, state) {
		this.context = context
		
		this.node = this.context.createBiquadFilter()

		this.node.type = state.type_
		this.node.frequency.value = state.frequency
		this.node.Q.value = state.q

		this.adsr = new ADSR(this.context, state.amp)

		// is this gain really necessary?
		this.filterEnvelopeGain = this.context.createGain()
		this.node.connect(this.filterEnvelopeGain)
	}

	_ = () => {}

	get type () {
		return this.node.type
	}

	connect = node => {
		this.filterEnvelopeGain.connect(node)
		return this
	}

	disconnect = node => {
		this.filterEnvelopeGain(node)
		return this
	}

	setCutoff = midiValue => {
		this.node.frequency.value = MIDI.toFilterCutoffFrequency(midiValue)
	}

	setQ = midiValue => {
		this.node.Q.value = MIDI.toFilterQAmount(midiValue)
	}

	setType = filterType => {
		if(CONSTANTS.FILTER_TYPES.includes(filterType.toLowerCase())) {
			this.node.type = filterType.toLowerCase()
		}
		else{
			throw new Error('Invalid Filter Type')
		}
	}

	toggleDistortion = state => {
		this.distortion = state
	}

	setAttack = midiValue => {
		this.adsr.attack = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

}