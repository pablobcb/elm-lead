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
	}

	_  = () => {}

	getValue = (start, end, fromTime, toTime, at) => {
		var difference = end - start
		var time = toTime - fromTime
		var truncateTime = at - fromTime
		var phase = truncateTime / time
		var value = start + phase * difference

		if (value <= start) {
			value = start
		}
		if (value >= end) {
			value = end
		}

		return value
	}

	on = (target) => {
		const now = this.context.currentTime
		this.startedAt = now
		this.decayFrom = now + this.attack
		target.cancelScheduledValues(now)
		target.setValueAtTime(0, now)
		target.linearRampToValueAtTime(this.amount, now + this.attack)
		//target.linearRampToValueAtTime(
		//	this.sustain, now + this.attack + this.decay)
		//target.setTargetAtTime(0.00001, now, 0.01)
		//target.setTargetAtTime(this.amount, now, this.attack)
		target.setTargetAtTime(this.sustain, now + this.attack, this.decay)
	}

	off = (target) => {		
		const now = this.context.currentTime

		const lastValue = this.getValue(0, this.amount, this.startedAt, this.decayFrom, now)
		target.cancelScheduledValues(now)

		if(this.attack && now < this.decayFrom) {
			target.setValueAtTime(lastValue, now)
			target.linearRampToValueAtTime(0, now + this.release)
		}
		else {
			target.setValueAtTime(this.sustain, now)
			target.linearRampToValueAtTime(0, now + this.release)
		}
		//target.cancelScheduledValues(now + this.release)
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
