import { expect } from 'chai'
import VCA from '../../src/ts/AudioEngine/VCA'
import CONSTANTS from '../../src/ts/Constants'
import 'web-audio-test-api'

describe('VCA', () => {
	const context: AudioContext = new AudioContext
	let vca: VCA

	beforeEach(() => {
		vca = new VCA(context)
	})

	it('constructor should set an AudioContext', () => {
		expect(vca.context).to.be.an.instanceOf(AudioContext)
	})

	it('constructor should set 128 input gains', () => {
		expect(vca.inputs).to.have.lengthOf(CONSTANTS.MAX_VOICES)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(vca.inputs[i]).to.exist
		}
	})
})
