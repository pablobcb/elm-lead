import { expect } from 'chai'
import { ADSR, ADSRState } from '../../src/ts/AudioEngine/ADSR'

describe('ADSR', () => {
	const context: AudioContext = {} as AudioContext
	let adsr: ADSR

	beforeEach(() => {
		adsr = new ADSR(context)
	})

	it('ADSR should always hold an AudioContext', () => {
		expect(adsr.context).to.exist
	})

	it('ADSR initial state should be empty', () => {
		expect(adsr.context).to.exist
	})

	it('ADSR initial values should be zero', () => {
		expect(adsr.startAmount).to.be.equal(0)
		expect(adsr.sustainAmount).to.be.equal(0)
		expect(adsr.startedAt).to.be.equal(0)
		expect(adsr.decayFrom).to.be.equal(0)
		expect(adsr.decayTo).to.be.equal(0)
		expect(adsr.endAmount).to.be.equal(0)
		expect(adsr.state).to.be.empty
	})
})
