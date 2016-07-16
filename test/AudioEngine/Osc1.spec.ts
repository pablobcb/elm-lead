import { expect } from 'chai'
import { Osc1, Osc1State } from '../../src/ts/AudioEngine/Osc1'
import CONSTANTS from '../../src/ts/Constants'
import "web-audio-test-api"

describe('Osc1', () => {
	const context:AudioContext = new AudioContext()
	let osc1: Osc1

	beforeEach(() => {
		osc1 = new Osc1(context)
	})

	it('constructor should set an AudioContext', () => {
		expect(osc1.context).to.exist
	})

	it('constructor should set an empty state object', () => {
		expect(osc1.state).to.be.empty
	})

	it('constructor should set 128 fm input gains', () => {
		expect(osc1.fmInputs).to.have.lengthOf(CONSTANTS.MAX_VOICES)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(osc1.fmInputs[i]).to.exist
		}
	})

	it('constructor should set 128 voice output gains', () => {
		expect(osc1.outputs).to.have.lengthOf(CONSTANTS.MAX_VOICES)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(osc1.outputs[i]).to.exist
		}
	})

	it('constructor should set 128 null voice oscs', () => {
		expect(osc1.outputs).to.have.lengthOf(CONSTANTS.MAX_VOICES)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(osc1.vcos[i]).to.be.null
		}
	})

	it('constructor should set 128 null voice oscs', () => {
		expect(osc1.outputs).to.have.lengthOf(CONSTANTS.MAX_VOICES)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(osc1.vcos[i]).to.be.null
		}
	})
})
