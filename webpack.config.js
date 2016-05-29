const autoprefixer = require('autoprefixer')

module.exports = {
	entry: './src/main.js',
	output: {
		path: `${__dirname}/dist`,
		filename: 'bundle.js'
	},
	module: {
		preLoaders: [
			{
				test: /\.styl$/,
				loader: 'stylint'
			},
			{
				test: /\.js$/,
				loader: 'eslint',
				exclude: /node_modules/
			}
		],
		loaders: [
			{
				test: /\.styl$/,
				loader: 'style!css!postcss!stylus'
			},
			{
				test: /\.elm$/,
				loader: 'elm-webpack',
				exclude: [/elm-stuff/, /node_modules/]
			},
			{
				test: /\.js$/,
				loader: 'babel',
				exclude: [/(node_modules)/],
				query: {
					presets: ['es2015'],
					plugins: [
						'transform-class-properties',
						'transform-function-bind'
					]
				}
			}
		]
	},
	resolve: {
		extensions: ['', '.js', '.styl', '.elm']
	},
	stylint: {
		config: `${__dirname}/.stylintrc`
	},
	postcss: () => [autoprefixer]
}
