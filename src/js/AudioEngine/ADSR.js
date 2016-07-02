import MIDI from '../MIDI'
import CONSTANTS from '../Constants'

export default class ADSR {
	//TODO: use 0.000001 for attack and release
	constructor (context, state) {
		this.state = state
		this.startAmount = 0
		this.state.envelopeAmount = state.envelopeAmount || 1
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

		if(difference >= 0)	{
			if (value <= start) {
				value = start
			}
			if (value >= end) {
				value = end
			}
		}
		else {
			if (value >= start) {
				value = start
			}
			if (value <= end) {
				value = end
			}
		}

		return value
	}

	on = (target, startAmount) => {
		const now = this.context.currentTime
		this.startedAt = now
		this.decayFrom = this.startedAt + this.state.attack
		this.decayTo = this.decayFrom + this.state.decay
		if(startAmount) {
			this.startAmount = startAmount
		}
		target.cancelScheduledValues(now)
		target.setValueAtTime(this.startAmount, now)
		target.linearRampToValueAtTime(this.startAmount + 
			this.state.envelopeAmount, this.decayFrom)
		target.linearRampToValueAtTime(this.state.sustain, this.decayTo)
	}

	off = target => {		
		const now = this.context.currentTime
		let valueAtTime = this.state.sustain

		target.cancelScheduledValues(now)

		if(this.attack && now < this.decayFrom) {
			valueAtTime = this.getValue(this.startAmount, this.state.envelopeAmount, this.startedAt, this.decayFrom, now)
		}
		else if(now >= this.decayFrom && now < this.decayTo) {
			valueAtTime = this.getValue(this.startAmount 
				+ this.state.envelopeAmount,
					this.state.sustain, this.decayFrom, this.decayTo, now)
		}

		target.setValueAtTime(valueAtTime, now)
		target.linearRampToValueAtTime(0, now + this.state.release)
		
		return now + this.state.release
	}

	setAttack = midiValue => {
		this.state.attack = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setDecay = midiValue => {
		this.state.decay = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setSustain = midiValue => {
		this.state.sustain = MIDI.logScaleToMax(midiValue, 1)
	}

	setRelease = midiValue => {
		this.state.release = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}
}
