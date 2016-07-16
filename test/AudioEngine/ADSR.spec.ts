import { expect } from 'chai'
import { ADSR, ADSRState } from '../../src/ts/AudioEngine/ADSR'
import CONSTANTS from '../../src/ts/Constants'

describe('ADSR', () => {
	const context: AudioContext = {} as AudioContext
	let adsr: ADSR

	beforeEach(() => {
		adsr = new ADSR(context)
	})

	it('constructor should set an AudioContext', () => {
		expect(adsr.context).to.exist
	})

	it('constructor should set an empty state object', () => {
		expect(adsr.state).to.be.empty
	})

	it('constructor should set initial values to zero', () => {
		expect(adsr.startAmount).to.be.equal(0)
		expect(adsr.sustainAmount).to.be.equal(0)
		expect(adsr.startedAt).to.be.equal(0)
		expect(adsr.decayFrom).to.be.equal(0)
		expect(adsr.decayTo).to.be.equal(0)
		expect(adsr.endAmount).to.be.equal(0)
	})

	it('setAttack should never set attack to zero', () => {
		adsr.setAttack(0)
		expect(adsr.state.attack).to.be.equal(CONSTANTS.ONE_MILLISECOND)
	})

	it('setAttack should never set attack greater than max time', () => {
		adsr.setAttack(CONSTANTS.MIDI_MAX_VALUE)
		expect(adsr.state.attack).to.be.equal(CONSTANTS.MAX_ENVELOPE_TIME)
	})

	it('setAttack should throw if value is greater than 127', () => {
		expect(adsr.setAttack.bind(adsr, CONSTANTS.MIDI_MAX_VALUE + 1))
			.to.throw(Error)
	})

	it('setAttack should throw if value is smaller than 0', () => {
		expect(adsr.setAttack.bind(adsr, -1))
			.to.throw(Error)
	})

	it('setDecay should be able to set decay to zero', () => {
		adsr.setDecay(0)
		expect(adsr.state.decay).to.be.equal(0)
	})

	it('setDecay should never set attack greater than max time', () => {
		adsr.setDecay(CONSTANTS.MIDI_MAX_VALUE)
		expect(adsr.state.decay).to.be.equal(CONSTANTS.MAX_ENVELOPE_TIME)
	})

	it('setDecay should throw if value is greater than 127', () => {
		expect(adsr.setDecay.bind(adsr, CONSTANTS.MIDI_MAX_VALUE + 1))
			.to.throw(Error)
	})

	it('setDecay should throw if value is smaller than 0', () => {
		expect(adsr.setDecay.bind(adsr, -1))
			.to.throw(Error)
	})

	it('setSustain should able to set sustain to zero', () => {
		adsr.setSustain(0)
		expect(adsr.state.sustain).to.be.equal(0)
	})

	it('setSustain should never set release greater than 1', () => {
		adsr.setSustain(CONSTANTS.MIDI_MAX_VALUE)
		expect(adsr.state.sustain).to.be.equal(1)
	})

	it('setSustain should throw if value is greater than 127', () => {
		expect(adsr.setSustain.bind(adsr, CONSTANTS.MIDI_MAX_VALUE + 1))
			.to.throw(Error)
	})

	it('setSustain should throw if value is smaller than 0', () => {
		expect(adsr.setSustain.bind(adsr, -1))
			.to.throw(Error)
	})

	it('setRelease should never set release to zero', () => {
		adsr.setRelease(0)
		expect(adsr.state.release).to.be.equal(CONSTANTS.ONE_MILLISECOND)
	})

	it('setRelease should never set attack greater than max time', () => {
		adsr.setRelease(CONSTANTS.MIDI_MAX_VALUE)
		expect(adsr.state.release).to.be.equal(CONSTANTS.MAX_ENVELOPE_TIME)
	})

	it('setRelease should throw if value is greater than 127', () => {
		expect(adsr.setRelease.bind(adsr, CONSTANTS.MIDI_MAX_VALUE + 1))
			.to.throw(Error)
	})

	it('setRelease should throw if value is smaller than 0', () => {
		expect(adsr.setRelease.bind(adsr, -1))
			.to.throw(Error)
	})

	it('setState should populate state', () => {
		adsr.setState({ attack: 0, decay: 0, sustain: 127, release: 127 })
		expect(adsr.state.attack).to.be.equal(CONSTANTS.ONE_MILLISECOND)
		expect(adsr.state.decay).to.be.equal(0)
		expect(adsr.state.sustain).to.be.equal(1)
		expect(adsr.state.release).to.be.equal(4)
	})

})
