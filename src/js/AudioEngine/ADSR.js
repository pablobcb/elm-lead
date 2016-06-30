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
	}

	_  = () => {}
	on = (target) => {
		const now = this.context.currentTime
		target.cancelScheduledValues(now)
		//target.setValueAtTime(0, now)
		target.linearRampToValueAtTime(this.amount, now + this.attack)
		target.linearRampToValueAtTime(
			this.sustain, now + this.attack + this.decay)
	}

	off = (target) => {		
		const now = this.context.currentTime
		target.cancelScheduledValues(now)
		//target.setValueAtTime(target.value, now)

		target.linearRampToValueAtTime(0.00001, now + this.release)
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
