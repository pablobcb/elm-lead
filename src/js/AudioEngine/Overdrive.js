import CONSTANTS from '../Constants'

export default class Overdrive {
	constructor (context, state) {
		this.context = context

		/* overdrive state */
		this.state = {}
		const params = CONSTANTS.OVERDRIVE_PARAMS

		/* internal AudioNodes */
		this._bandpass = this.context.createBiquadFilter()
		this._bpWet = this.context.createGain()
		this._bpDry = this.context.createGain()
		this._ws = this.context.createWaveShaper()
		this._lowpass = this.context.createBiquadFilter()

		/* AudioNode graph routing */
		this.input = this.context.createGain()
		this.output = this.context.createGain()

		this.input.connect(this._bandpass)
		this._bandpass.connect(this._bpWet)
		this._bandpass.connect(this._bpDry)
		this._bpWet.connect(this._ws)
		this._bpDry.connect(this._ws)
		this._ws.connect(this._lowpass)
		this._lowpass.connect(this.output)

		/* assign overdrive default values */
		this._bandpass.frequency.value = params.color
		this._bpWet.gain.value = params.preBand
		this._lowpass.frequency.value = params.postCut
		this.drive = params.drive
		this._bpDry.gain.value = 1 - params.preBand

		this.setState(state)
	}

	connect = node => {
		this.output.connect(node.input ? node.input : node)
	}

	disconnect = () => {
		this.output.disconnect()
	}

	setState = isOn => {
		this.state.on = isOn
		this.input.disconnect()
		if (isOn) {
			this.input.connect(this._bandpass)
		} else {
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
