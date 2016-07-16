import { expect } from 'chai'
import { Amplifier, AmplifierState } from '../../src/ts/AudioEngine/Amplifier'
import { ADSR, ADSRState } from '../../src/ts/AudioEngine/ADSR'
import CONSTANTS from '../../src/ts/Constants'
import 'web-audio-test-api'

describe('Amplifier', () => {
	const context: AudioContext = new AudioContext
	let amplifier: Amplifier

	beforeEach(() => {
		amplifier = new Amplifier(context)
	})

	it('constructor should set an AudioContext', () => {
		expect(amplifier.context).to.be.an.instanceOf(AudioContext)
	})

	it('constructor should set an empty state object', () => {
		expect(amplifier.state).to.be.empty
	})

	it('constructor should set an output', () => {
		expect(amplifier.state).to.exist
	})

	it('constructor should set an output', () => {
		expect(amplifier.state).to.exist
	})

	it('constructor should set an ADSR', () => {
		expect(amplifier.adsr).to.be.an.instanceOf(ADSR)
	})

	it('setMasterVolumeGain should set volume at maximum to 1', () => {
		amplifier.setMasterVolumeGain(CONSTANTS.MIDI_MAX_VALUE)
		expect(amplifier.state.masterVolume).to.be.equal(1)
	})

	it('setMasterVolumeGain should throw if value is smaller than 0', () => {
		expect(amplifier.setMasterVolumeGain.bind(amplifier, -1))
			.to.throw(Error)
	})

	it('setMasterVolumeGain should throw if value is greater than max', () => {
		expect(amplifier.setMasterVolumeGain
			.bind(amplifier, CONSTANTS.MIDI_MAX_VALUE + 1)).to.throw(Error)
	})

	it('setState should populate amp state ', () => {
		amplifier.setState({
			masterVolume: CONSTANTS.MIDI_MAX_VALUE,
			adsr: {
				attack: CONSTANTS.MIDI_MAX_VALUE,
				decay: CONSTANTS.MIDI_MAX_VALUE,
				sustain: CONSTANTS.MIDI_MAX_VALUE,
				release: CONSTANTS.MIDI_MAX_VALUE
			}
		})

		expect(amplifier.state.masterVolume).to.be.equal(1)

		expect(amplifier.adsr.state.attack)
			.to.be.equal(CONSTANTS.MAX_ENVELOPE_TIME)

		expect(amplifier.adsr.state.decay)
			.to.be.equal(CONSTANTS.MAX_ENVELOPE_TIME)

		expect(amplifier.adsr.state.sustain).to.be.equal(1)

		expect(amplifier.adsr.state.release)
			.to.be.equal(CONSTANTS.MAX_ENVELOPE_TIME)
	})
})
