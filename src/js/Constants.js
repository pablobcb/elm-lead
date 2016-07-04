export default {
	MAX_NOTES: 128,
	ONE_MILLISECOND: 0.001,
	FILTER_TYPE: {
		HIGHPASS: 'highpass',
		LOWPASS: 'lowpass',
		BANDPASS: 'bandpass',
		NOTCH: 'notch'
	},
	FILTER_TYPES: ['highpass', 'lowpass', 'bandpass', 'notch'],
	WAVEFORM_TYPE: {
		SAWTOOTH: 'sawtooth',
		TRIANGLE: 'triangle',
		SINE: 'sine',
		SQUARE: 'square',
		NOISE: 'whitenoise',
		PULSE: 'pulse'
	},
	OSC1_WAVEFORM_TYPES: ['sine', 'triangle', 'sawtooth', 'square'],
	OSC2_WAVEFORM_TYPES: ['triangle', 'sawtooth', 'pulse', 'whitenoise'],
	MIDI_EVENT: {
		NOTE_ON: 144,
		NOTE_OFF: 128
	},
	MAX_ENVELOPE_TIME: 4, // in seconds
	OVERDRIVE_PARAMS : {
		preBand: 1.0,
		color: 4000,
		drive: .8,
		postCut: 8000
	},
	MIN_FILTER_FREQUENCY: 0,
	MAX_FILTER_FREQUENCY: 22050
}
