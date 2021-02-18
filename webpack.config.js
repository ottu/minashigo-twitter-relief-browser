const path = require("path")
const { VueLoaderPlugin } = require("vue-loader")

module.exports = {
	mode: "development",

	entry: path.join(__dirname, "./ts/main.ts"),
	output: {
		path: path.join(__dirname, "/public/js"),
		filename: "main.bundle.js"
	},

	module: {
		rules: [
			{
				test: /.vue$/,
				use: "vue-loader",
			},
			{
				test: /\.ts/,
				use: [{
					loader: "ts-loader",
					options: {
						appendTsSuffixTo: [/\.vue$/]
					}
				}]
			},
			{
				test: /\.css$/,
				use: ["style-loader", "css-loader"]
			},
			
		]
	},
	plugins: [
		new VueLoaderPlugin()
	],
	resolve: {
		extensions: [
			'.ts', '.js', '.vue'
		],
		alias: {
			"vue$": "vue/dist/vue.esm.js"
		}
	}
}
