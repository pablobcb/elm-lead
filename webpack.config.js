const autoprefixer = require('autoprefixer')

module.exports = {
	entry: './src/js/main.js',
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
				test: /\.css$/,
				loader: 'style!css!postcss'
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
						'transform-function-bind',
						'transform-class-properties'
					]
				}
			}
		]
	},
	resolve: {
		extensions: ['', '.js', '.styl', '.elm', '.css']
	},
	stylint: {
		config: `${__dirname}/.stylintrc`
	},
	postcss: () => [autoprefixer]
}
