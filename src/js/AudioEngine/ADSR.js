import CONSTANTS from '../Constants'
import MIDI from './MIDI'

export default class ADSR {
	//TODO: use 0.000001 for attack and release
	constructor (context, a, d, s, r, amount) {
		this.attack = a
		this.decay = d
		this.sustain = s
		this.release = r
		this.amount = amount
		this.context = context
		this.startedAt = 0
		this.decayFrom = 0
		this.decayTo = 0
	}

	_  = () => {}

	getValue = (start, end, fromTime, toTime, at) => {
		var difference = end - start
		var time = toTime - fromTime
		var truncateTime = at - fromTime
		var phase = truncateTime / time
		var value = start + phase * difference

		if(difference >= 0)
		{
			if (value <= start) {
				value = start
			}
			if (value >= end) {
				value = end
			}
		}
		else
		{
			if (value >= start) {
				value = start
			}
			if (value <= end) {
				value = end
			}
		}

		return value
	}

	on = (target) => {
		const now = this.context.currentTime
		this.startedAt = now
		this.decayFrom = this.startedAt + this.attack
		this.decayTo = this.decayFrom + this.decay

		target.cancelScheduledValues(now)
		target.setValueAtTime(0, now)
		target.linearRampToValueAtTime(this.amount, this.decayFrom)
		target.linearRampToValueAtTime(this.sustain, this.decayTo)
		//target.setTargetAtTime(this.sustain, now + this.attack, this.decay)
	}

	off = (target) => {		
		const now = this.context.currentTime
		let valueAtTime = this.sustain

		target.cancelScheduledValues(now)

		if(this.attack && now < this.decayFrom) {
			valueAtTime = this.getValue(0, this.amount, 
				this.startedAt, this.decayFrom, now)
		}
		else if(now >= this.decayFrom && now < this.decayTo) {
			
			valueAtTime = this.getValue(this.amount, this.sustain, 
				this.decayFrom, this.decayTo, now)
		}

		target.setValueAtTime(valueAtTime, now)
		target.linearRampToValueAtTime(0, now + this.release)
		
		return now + this.release
	}

	setAttack = (midiValue) => {
		this.attack = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setDecay = (midiValue) => {
		this.decay = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	setSustain = (midiValue) => {
		this.sustain = MIDI.logScaleToMax(midiValue, 1)
	}

	setRelease = (midiValue) => {
		this.release = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}
}
