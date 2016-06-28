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

	on = (target) => {
		const now = this.context.currentTime
		target.cancelScheduledValues(now)
		target.setValueAtTime(0, now)
		target.linearRampToValueAtTime(this.amount, now + this.attack)
		target.linearRampToValueAtTime(
			this.sustain, now + this.attack + this.decay)
	}

	off = (target, osc) => {
		const now = this.context.currentTime
		//target.cancelScheduledValues(now)
		//target.setValueAtTime(target.value, now)
		//target.setTargetAtTime(0.00001, now, this.release)
		target.value = 0.0
		//target.linearRampToValueAtTime(0.1, now + this.release)
		osc.stop(now + this.release)
		//debugger
	}
}
