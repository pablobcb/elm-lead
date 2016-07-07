const autoprefixer = require('autoprefixer')

module.exports = {
	entry: './src/ts/index.ts',
	output: {
		path: `${__dirname}/dist`,
		filename: 'bundle.js'
	},
	module: {
		preLoaders: [
			{
				test: /\.styl$/,
				loader: 'stylint'
			}
		],
		loaders: [
			{
				test: /\.svg/,
				loader: 'svg-url-loader'
			},
			{
				test: /\.json$/,
				loader: 'json'
			},
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
				test: /\.(ttf|eot|woff(2)?)(\?[a-z0-9=&.]+)?$/,
				loader: 'file-loader'
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
			},
			{
				test: /\.ts$/,
				loader: 'ts-loader'
			}
		]
	},
	resolve: {
		extensions: ['', '.js', '.ts', '.styl', '.elm', '.css']
	},
	stylint: {
		config: `${__dirname}/.stylintrc`
	},
	postcss: () => [autoprefixer]
}
