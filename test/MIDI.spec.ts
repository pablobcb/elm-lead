import { expect } from 'chai'
import MIDI from '../src/ts/MIDI'
import CONSTANTS from '../src/ts/Constants'

describe('MIDI', () => {
	it('validateValue should throw if value is greater than 127', () => {
		expect(MIDI.validateValue.bind(MIDI, CONSTANTS.MIDI_MAX_VALUE + 0.1))
			.to.throw(Error)
	})

	it('validateValue should throw if value is smaller than 0', () => {
		expect(MIDI.validateValue.bind(MIDI, -1))
			.to.throw(Error)
	})

	it('toFreq should return 440 given A4', () => {
		expect(MIDI.toFrequency(69)).to.be.equal(440)
	})
})