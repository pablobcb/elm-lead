import { expect } from 'chai'
import VCA from '../../src/ts/AudioEngine/VCA'
import CONSTANTS from '../../src/ts/Constants'

describe('VCA', () => {
	const context: AudioContext = {} as AudioContext
	let vca: VCA

	beforeEach(() => {
		vca = new VCA(context)
	})

	it('constructor should set an AudioContext', () => {
		expect(vca.context).to.exist
	})


})
