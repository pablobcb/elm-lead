export default class Overdrive {
	constructor (context, opts) {
		this.input = context.createGain()
		this.output = context.createGain()

		// Internal AudioNodes
		this._bandpass = context.createBiquadFilter()
		this._bpWet = context.createGain()
		this._bpDry = context.createGain()
		this._ws = context.createWaveShaper()
		this._lowpass = context.createBiquadFilter()

		// AudioNode graph routing
		this.input.connect(this._bandpass)
		this._bandpass.connect(this._bpWet)
		this._bandpass.connect(this._bpDry)
		this._bpWet.connect(this._ws)
		this._bpDry.connect(this._ws)
		this._ws.connect(this._lowpass)
		this._lowpass.connect(this.output)

		// params
		this.params = {
			preBand: {
				min: 0,
				max: 1.0,
				defaultValue: 0.5,
				type: 'float'
			},
			color: {
				min: 0,
				max: 22050,
				defaultValue: 800,
				type: 'float'
			},
			drive: {
				min: 0.0,
				max: 1.0,
				defaultValue: 0.5,
				type: 'float'
			},
			postCut: {
				min: 0,
				max: 22050,
				defaultValue: 3000,
				type: 'float'
			}
		}

		opts = opts || {}
		this._bandpass.frequency.value = 
			opts.color || this.params.color.defaultValue

		this._bpWet.gain.value =
			opts.preBand || this.params.preBand.defaultValue

		this._lowpass.frequency.value =
			opts.postCut || this.postCut.defaultValue

		this.drive = 
			opts.drive || this.drive.defaultValue

		// Inverted preBand value
		this._bpDry.gain.value = opts.preBand
			? 1 - opts.preBand
			: 1 - this.params.preBand.defaultValue
	}

	connect = node => {
		this.output.connect(node.input ? node.input : node)
	}

	disconnect = () => {
		this.output.disconnect()
	}

	toggle = on => {
		this.input.disconnect()
		if (on) {
			this.input.connect(this._bandpass)
		}
		else {
			this.input.connect(this.output)
		}
	}

	get preBand () {
		return this._bpWet.gain.value
	}

	set preBand (value) {
		this._bpWet.gain.setValueAtTime(value, 0)
		this._bpDry.gain.setValueAtTime(1 - value, 0)
	}

	get color () {
		return this._bandpass.frequency.value
	}

	set color (value) {
		this._bandpass.frequency.setValueAtTime(value, 0)
	}

	get drive () {
		return this._drive
	}

	set drive (value) {
		const k = value * 100
			, n = 22050
			, curve = new Float32Array(n)
			, deg = Math.PI / 180

		this._drive = value
		for (let i = 0; i < n; i++) {
			const x = i * 2 / n - 1
			curve[i] = (3 + k) * x * 20 * deg / (Math.PI + k * Math.abs(x))
		}
		this._ws.curve = curve
	}

	get postCut () {
		return this._lowpass.frequency.value
	}

	set postCut (value) {
		this._lowpass.frequency.setValueAtTime(value, 0)
	}

}