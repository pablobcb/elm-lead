import CONSTANTS from '../Constants'


/* code copied from https://github.com/web-audio-components/overdrive */
export class Overdrive {

	public input: GainNode
	public output: GainNode

	public enabled: boolean

	private _bandpass: BiquadFilterNode
	private _bpWet: GainNode
	private _bpDry: GainNode
	private _ws: WaveShaperNode
	private _lowpass: BiquadFilterNode
	private _drive: number
	private context: AudioContext

	public params: any

	constructor (context: AudioContext, enabled: boolean) {
		this.context = context

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

		this._bpWet.gain.value = params.preBand
		this._lowpass.frequency.value = params.postCut
		this.drive = params.drive

		// Inverted preBand value
		this._bpDry.gain.value = params.preBand

		this.setState(enabled)
	}

	connect = (node: any) => {
		this.output.connect(node.input ? node.input : node)
	}

	disconnect = () => {
		this.output.disconnect()
	}

	setState = (enabled: boolean) => {
		this.enabled = enabled
		this.input.disconnect()
		if (enabled) {
			this.input.connect(this._bandpass)
		} else {
			this.input.connect(this.output)
		}
	}

	get preBand() {
		return this._bpWet.gain.value
	}

	set preBand(value: number) {
		this._bpWet.gain.setValueAtTime(value, 0)
		this._bpDry.gain.setValueAtTime(1 - value, 0)
	}

	get color() {
		return this._bandpass.frequency.value
	}

	set color(value: number) {
		this._bandpass.frequency.setValueAtTime(value, 0)
	}

	get drive() {
		return this._drive
	}

	set drive(value: number) {
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

	get postCut() {
		return this._lowpass.frequency.value
	}

	set postCut(value: number) {
		this._lowpass.frequency.setValueAtTime(value, 0)
	}

}
