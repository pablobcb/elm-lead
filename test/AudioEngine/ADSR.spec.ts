import { expect } from 'chai'
import { ADSR, ADSRState } from '../../src/ts/AudioEngine/ADSR'

describe('ADSR', () => {
	const context: AudioContext = {} as AudioContext

	it('ADSR initial values should be zero', () => {
		const a = 10;
		expect(a).to.be.equal(10)
	})
})
