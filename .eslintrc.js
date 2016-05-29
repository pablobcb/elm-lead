module.exports = {
	parser: "babel-eslint",
	env: {
		browser: true,
		es6: true,
		node: true
	},
	extends: "eslint:recommended",
	parserOptions: {
		sourceType: "module"
	},
	plugins: [
		"flowtype"
	],
	rules: {
		"indent": [ "warn", "tab", { "SwitchCase": 1 } ],
		"linebreak-style": [ "warn", "unix" ],
		"max-len": [ "warn", 80 ],
		"no-console": [ "off" ],
		"no-debugger": [ "warn" ],
		"no-redeclare": [ "warn" ],
		"no-undef": [ "warn" ],
		"no-unused-vars": [ "warn" ],
		"no-var": [ "warn" ],
		"prefer-const": [ "warn" ],
		"prefer-template": [ "warn" ],
		"quotes": [ "warn", "single" ],
		"semi": [ "warn", "never" ],
		"space-before-function-paren": [ "warn" ],
		"space-in-parens": ["warn", "never"],

		"flowtype/require-parameter-type": ["warn", "always"],
		"flowtype/require-return-type": ["warn", "always"],
		"flowtype/space-after-type-colon": ["warn", "always"],
		"flowtype/space-before-type-colon": ["warn", "always"]
	}
}
