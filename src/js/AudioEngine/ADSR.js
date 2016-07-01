export default class ADSR {
	//TODO: use 0.000001 for attack and release
	constructor (context, maxAmount) {
		this.startAmount = 0
		this.maxAmount = maxAmount
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

	on = adsr => 
		(target, startAmount) => {
			this.attack = adsr.attack
			this.decay = adsr.decay
			this.sustain = adsr.sustain
			this.release = adsr.release
			const now = this.context.currentTime
			this.startedAt = now
			this.decayFrom = this.startedAt + this.attack
			this.decayTo = this.decayFrom + this.decay

			if(startAmount) {
				this.startAmount = startAmount
			}

			target.cancelScheduledValues(now)
			target.setValueAtTime(this.startAmount, now)
			target.linearRampToValueAtTime(this.startAmount + 
				this.maxAmount, this.decayFrom)
			target.linearRampToValueAtTime(this.sustain, this.decayTo)
		}

	off = (target) => {		
		const now = this.context.currentTime
		let valueAtTime = this.sustain

		target.cancelScheduledValues(now)

		if(this.attack && now < this.decayFrom) {
			valueAtTime = this.getValue(this.startAmount, this.maxAmount, 
				this.startedAt, this.decayFrom, now)
		}
		else if(now >= this.decayFrom && now < this.decayTo) {			
			valueAtTime = this.getValue(this.startAmount + 
				this.maxAmount, this.sustain, this.decayFrom, this.decayTo, now)
		}

		target.setValueAtTime(valueAtTime, now)
		target.linearRampToValueAtTime(0, now + this.release)
		
		return now + this.release
	}	
}
