export default class ADSR {
	//TODO: use 0.000001 for attack and release
	constructor (context, a, d, s, r, level) {
		this.attack = a
		this.decay = d
		this.sustain = s
		this.release = r
		this.level = level
		this.amount = 10
		this.context = context
	}

	on = (target) => {
		const now = this.context.currentTime
		target.cancelScheduledValues(now)
		target.setValueAtTime(0, now)
		target.linearRampToValueAtTime(this.amount, now + this.attack)
		target.linearRampToValueAtTime(
			this.sustain, now + this.attack + this.decay)
	}

	off = (at, target) => {
		const now = this.context.currentTime
		target.cancelScheduledValues(now)
		target.stop()
		//this.target.linearRampToValueAtTime(this.s, now + this.r)
	}
}
