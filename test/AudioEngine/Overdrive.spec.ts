import { expect } from 'chai'
import Overdrive from '../../src/ts/AudioEngine/Overdrive'
import CONSTANTS from '../../src/ts/Constants'
import 'web-audio-test-api'

describe('Overdrive', () => {
	const context: AudioContext = new AudioContext
	let overdrive: Overdrive

	beforeEach(() => {
		overdrive = new Overdrive(context)
	})

	it('constructor should set an AudioContext', () => {
		expect(overdrive.context).to.be.an.instanceOf(AudioContext)
	})

	it('constructor should set an input gain', () => {
		expect(overdrive.input).to.be.an.instanceOf(GainNode)
	})

	it('constructor should set an output gain', () => {
		expect(overdrive.output).to.be.an.instanceOf(GainNode)
	})

	it('constructor should bypass overdrive effect chain', () => {
		expect(overdrive.enabled).to.be.false
	})

	it('setState should change the state', () => {
		overdrive.setState(true)
		expect(overdrive.enabled).to.be.true
	})
})
