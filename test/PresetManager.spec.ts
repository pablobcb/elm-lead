import { expect } from 'chai'
import PresetManager from '../src/ts/PresetManager'
import CONSTANTS from '../src/ts/Constants'

describe('PresetManager', () => {
	const list = [1, 2, 3, 4, 5]
	let presetManager: PresetManager<number>

	beforeEach(() => {
		presetManager = new PresetManager(list)
	})

	it('constructor should set currentPresetIndex to zero', () => {
		expect(presetManager.currentPresetIndex).to.be.eql(0)
	})

	it('constructor should set preset list with the same size as input', () => {
		expect(presetManager.presets.length).to.be.eql(list.length)
	})

	it('constructor should throw if preset list is empty', () => {
		expect(() => new PresetManager([])).to.throw(Error)
	})

	it('current should return the current preset', () => {
		expect(presetManager.current()).to.be.eql(list[0])
	})

	it('next should return the next preset', () => {
		expect(presetManager.next()).to.be.eql(list[1])
	})

	it('next should go back to head of the list if called on last element',
		() => {
			presetManager.currentPresetIndex = list.length - 1
			expect(presetManager.next()).to.be.eql(list[0])
		})

	it('previous should return the previous preset', () => {
		presetManager.currentPresetIndex = 1
		expect(presetManager.previous()).to.be.eql(list[0])
	})

	it('previous should go to the end of the list if called on last element',
		() => {
			expect(presetManager.previous()).to.be.eql(list[list.length - 1])
		})
})