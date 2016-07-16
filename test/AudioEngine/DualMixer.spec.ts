import { expect } from 'chai'
import DualMixer from '../../src/ts/AudioEngine/DualMixer'
import CONSTANTS from '../../src/ts/Constants'
import 'web-audio-test-api'

describe('DualMixer', () => {
	const context: AudioContext = new AudioContext
	let mixer: DualMixer

	beforeEach(() => {
		mixer = new DualMixer(context)
	})

	it('constructor should set an audiocontext', () => {
		expect(mixer.context).to.be.an.instanceof(AudioContext)
	})

	it('constructor should set 128 gains for each channel', () => {
		expect(mixer.channel1).to.have.lengthOf(CONSTANTS.MAX_VOICES)
		expect(mixer.channel2).to.have.lengthOf(CONSTANTS.MAX_VOICES)

		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(mixer.channel1[i]).to.be.an.instanceOf(GainNode)
			expect(mixer.channel2[i]).to.be.an.instanceOf(GainNode)
		}
	})

	it('setState with 0 should mute osc 2', () => {
		mixer.setState(0)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(mixer.channel2[i].gain.value)
				.to.be.eql(0)

			expect(mixer.channel1[i].gain.value)
				.to.be.eql(0.5)
		}
	})

	it('setState with 0 should mute osc 1', () => {
		mixer.setState(CONSTANTS.MIDI_MAX_VALUE)
		for (let i = 0; i < CONSTANTS.MAX_VOICES; i++) {
			expect(mixer.channel2[i].gain.value)
				.to.be.eql(0.5)

			expect(mixer.channel1[i].gain.value)
				.to.be.eql(0)
		}
	})

	it('setState should throw if mix is greater than 127', () => {
		expect(mixer.setState.bind(mixer, CONSTANTS.MIDI_MAX_VALUE + 0.1))
			.to.throw(Error)
	})

	it('setState should throw if mix is smaller than 0', () => {
		expect(mixer.setState.bind(mixer, -1))
			.to.throw(Error)
	})

})
