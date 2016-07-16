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
		expect(MIDI.toFrequency(69)).to.be.eql(440)
	})

	it('logScaleToMax should never return a value greater than max', () => {
		expect(MIDI.logScaleToMax(127, 399)).to.be.eql(399)
	})

	it('logScaleToMax should return zero with zero as an argument', () => {
		expect(MIDI.logScaleToMax(0, 399)).to.be.eql(0)

	})

	it('normalizeValue should return zero with zero as an argument', () => {
		expect(MIDI.normalizeValue(0)).to.be.eql(0)
	})

	it('normalizeValue should return 1 with 127 as an argument', () => {
		expect(MIDI.normalizeValue(CONSTANTS.MIDI_MAX_VALUE)).to.be.eql(1)
	})
})