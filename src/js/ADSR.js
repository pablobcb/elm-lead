export default class ADSR {
	//TODO: use 0.000001 for attack and release
	constructor (a, d, s, r, target, context) {
		this.a = a
		this.d = d
		this.s = s
		this.r = r

		this.amount = 2
		this.target = target
		this.context = context
		
		
	}


	on = () => {
		const now = this.context.currentTime
		//debugger
		this.target.cancelScheduledValues(now)
		this.target.setValueAtTime(0, now)
		this.target.linearRampToValueAtTime(this.amount, now + this.a)
		this.target.linearRampToValueAtTime(this.s, now + this.a + this.d)		
	}

	off = () => {
		this.target.linearRampToValueAtTime(this.s, now + athis.r)
	}
}