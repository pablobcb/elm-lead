export default {

	frequencyFromNoteNumber (note : number) : number {
		return 440 * Math.pow(2, (note - 69) / 12)
	}

	// function logger(container, label, data) {
	// 	const messages = label + ' [channel: ' + (data[0] & 0xf) +
	// 		', cmd: ' +
	// 		(data[0] >> 4) + ', type: ' + (data[0] & 0xf0) + ' , note: ' +
	// 		data[1] + ' , velocity: ' + data[2] + ']'

	// 	console.log(messages)
	// }

}
