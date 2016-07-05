import MIDI from '../MIDI'
import CONSTANTS from '../Constants'


export default class ADSR {
	//TODO: use 0.000001 for attack and release
	constructor (context, state) {
		this.state = state
		this.state.attack = this.state.attack || CONSTANTS.ONE_MILLISECOND
		this.state.release = this.state.release || CONSTANTS.ONE_MILLISECOND

		this.startAmount = 0
		this.sustainAmount = 0
		this.endAmount = 1
		this.context = context
		this.startedAt = 0
		this.decayFrom = 0
		this.decayTo = 0
	}

	_  = () => {}

	getValue = (start, end, fromTime, toTime, at) => {
		const difference = end - start
		const time = toTime - fromTime
		const truncateTime = at - fromTime
		const phase = truncateTime / time
		let value = start + phase * difference

		if (difference >= 0)	{
			if (value <= start) {
				value = start
			}
			if (value >= end) {
				value = end
			}
		} else {
			if (value >= start) {
				value = start
			}
			if (value <= end) {
				value = end
			}
		}

		return value
	}

	on = (startAmount, endAmount) => target => {
		const now = this.context.currentTime
		this.startedAt = now
		this.decayFrom = this.startedAt + this.state.attack
		this.decayTo = this.decayFrom + this.state.decay
		this.startAmount = startAmount
		this.endAmount = endAmount
		this.sustainAmount = this.state.sustain *
			(this.endAmount - this.startAmount) + this.startAmount
		//debugger
		target.cancelScheduledValues(now)
		target.setValueAtTime(this.startAmount, now)
		target.linearRampToValueAtTime(this.endAmount, this.decayFrom)
		target.linearRampToValueAtTime(this.sustainAmount, this.decayTo)
	}

	off = target => {
		const now = this.context.currentTime
		const valueAtTime = this.getValueAtTime(now)

		target.cancelScheduledValues(now)
		target.setValueAtTime(valueAtTime, now)
		target.linearRampToValueAtTime(this.startAmount,
			now + this.state.release)

		return now + this.state.release
	}

	getValueAtTime = now => {
		let valueAtTime = this.sustainAmount

		if (now >= this.state.attack && now < this.decayFrom) {
			valueAtTime = this.getValue(this.startAmount, this.endAmount,
				this.startedAt, this.decayFrom, now)
		} else if (now >= this.decayFrom && now < this.decayTo) {
			valueAtTime = this.getValue(this.endAmount,	this.sustainAmount,
				this.decayFrom, this.decayTo, now)
		}

		return valueAtTime
	}

	setAttack = midiValue => {
		this.state.attack = midiValue != 0 ?
			MIDI.logScaleToMax(midiValue,CONSTANTS.MAX_ENVELOPE_TIME) :
			CONSTANTS.ONE_MILLISECOND
	}

	setDecay = midiValue => {
		this.state.decay = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setSustain = midiValue => {
		this.state.sustain = MIDI.logScaleToMax(midiValue, 1)
	}

	setRelease = midiValue => {
		this.state.release = midiValue != 0 ?
			MIDI.logScaleToMax(midiValue,CONSTANTS.MAX_ENVELOPE_TIME) :
			CONSTANTS.ONE_MILLISECOND
	}
}
