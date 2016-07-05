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
	],
	rules: {
		"brace-style": [ "warn", "1tbs" ],
		"curly": [ "warn", "all" ],
		"indent": [ "warn", "tab", { "SwitchCase": 1 } ],
		"keyword-spacing": [ "warn" ],
		"linebreak-style": [ "warn", "unix" ],
		"max-len": [ "warn", 80 ],
		"no-console": [ "off" ],
		"no-debugger": [ "warn" ],
		"no-mixed-spaces-and-tabs": [ "warn" ],
		"no-redeclare": [ "warn" ],
		"no-undef": [ "warn" ],
		"no-unused-vars": [ "warn" ],
		"no-var": [ "warn" ],
		"prefer-const": [ "warn" ],
		"prefer-template": [ "warn" ],
		"quotes": [ "warn", "single" ],
		"semi": [ "warn", "never" ],
		"space-before-blocks": ["warn", "always"],
		"space-before-function-paren": [ "warn" ],
		"space-in-parens": ["warn", "never"],
	}
}
