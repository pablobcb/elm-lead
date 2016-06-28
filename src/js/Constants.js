export default {
	MAX_NOTES: 128,
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
		SINE : 'sine',
		SQUARE : 'square',
		NOISE : 'whitenoise'
	},
	OSC1_WAVEFORM_TYPES: ['sine', 'triangle', 'sawtooth', 'square'],
	OSC2_WAVEFORM_TYPES: ['triangle', 'sawtooth', 'square', 'whitenoise'],
	MIDI_EVENT: {
		NOTE_ON: 144,
		NOTE_OFF: 128
	},
	MAX_ENVELOPE_TIME: 5 // in seconds
}
