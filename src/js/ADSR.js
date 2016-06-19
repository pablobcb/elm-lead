export default class ADSR {
	//TODO: use 0.000001 for attack and release
	constructor(a, d, s, r, target, context) {
		this.a = a
		this.d = d
		this.s = s
		this.r = r

		this.amount = 10
		this.target = target
		this.context = context


	}


	on = () => {
		const now = this.context.currentTime
		this.target.cancelScheduledValues(now)
		this.target.setValueAtTime(0, now)
		this.target.linearRampToValueAtTime(this.amount, now + this.a)
		this.target.linearRampToValueAtTime(this.s, now + this.a + this.d)
	}

	off = (at) => {
		this.target.linearRampToValueAtTime(this.s, at + this.r)
	}
}