import MIDI from '../MIDI'
import CONSTANTS from '../Constants'

type Seconds = number

export interface ADSRState {
	attack: Seconds
	decay: Seconds
	sustain: number
	release: Seconds
}

export class ADSR {
	public state: ADSRState = {} as ADSRState
	public context: AudioContext
	public startAmount: number
	public sustainAmount: number
	public endAmount: number
	public startedAt: number
	public decayFrom: number
	public decayTo: number

	constructor(context: AudioContext) {
		this.context = context
		this.startAmount = 0
		this.sustainAmount = 0
		this.endAmount = 0
		this.startedAt = 0
		this.decayFrom = 0
		this.decayTo = 0
	}

	private getValue = (start: number, end: number, fromTime: number, toTime: number, at: number) => {
		const difference = end - start
		const time = toTime - fromTime
		const truncateTime = at - fromTime
		const phase = truncateTime / time
		let value = start + phase * difference

		if (difference >= 0) {
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

	private getValueAtTime = (now: number) => {
		let valueAtTime: number = this.sustainAmount

		if (now >= this.state.attack && now < this.decayFrom) {
			valueAtTime = this.getValue(this.startAmount, this.endAmount,
				this.startedAt, this.decayFrom, now)
		} else if (now >= this.decayFrom && now < this.decayTo) {
			valueAtTime = this.getValue(this.endAmount, this.sustainAmount,
				this.decayFrom, this.decayTo, now)
		}

		return valueAtTime
	}

	public on = (startAmount: number, endAmount: number) =>
		(target: AudioParam) => {
			console.log("range", startAmount, endAmount)

			const now = this.context.currentTime
			this.startedAt = now
			this.decayFrom = this.startedAt + this.state.attack
			this.decayTo = this.decayFrom + this.state.decay
			this.startAmount = startAmount
			this.endAmount = endAmount
			this.sustainAmount = this.state.sustain *
				(this.endAmount - this.startAmount) + this.startAmount

			target.cancelScheduledValues(now)
			target.setValueAtTime(this.startAmount, now)
			target.linearRampToValueAtTime(this.endAmount, this.decayFrom)
			target.linearRampToValueAtTime(this.sustainAmount, this.decayTo)
		}

	public off = (target: AudioParam) => {
		const now = this.context.currentTime
		const valueAtTime = this.getValueAtTime(now)

		target.cancelScheduledValues(now)
		target.setValueAtTime(target.value, now)
		target.linearRampToValueAtTime(this.startAmount,
			now + this.state.release)

		return now + this.state.release
	}


	public setAttack = (midiValue: number) => {
		MIDI.validateValue(midiValue)
		this.state.attack = midiValue != 0 ?
			MIDI.logScaleToMax(midiValue, CONSTANTS.MAX_ENVELOPE_TIME) :
			CONSTANTS.ONE_MILLISECOND
	}

	public setDecay = (midiValue: number) => {
		MIDI.validateValue(midiValue)
		this.state.decay = MIDI.logScaleToMax(midiValue,
			CONSTANTS.MAX_ENVELOPE_TIME)
	}

	public setSustain = (midiValue: number) => {
		MIDI.validateValue(midiValue)
		this.state.sustain = MIDI.logScaleToMax(midiValue, 1)
	}

	public setRelease = (midiValue: number) => {
		MIDI.validateValue(midiValue)
		this.state.release = midiValue != 0 ?
			MIDI.logScaleToMax(midiValue, CONSTANTS.MAX_ENVELOPE_TIME) :
			CONSTANTS.ONE_MILLISECOND
	}

	public setState = (state: ADSRState) => {
		this.setAttack(state.attack)
		this.setDecay(state.decay)
		this.setSustain(state.sustain)
		this.setRelease(state.release)
	}
}
