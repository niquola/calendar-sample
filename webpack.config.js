var etx = require("extract-text-webpack-plugin");
var webpack = require("webpack");
var path = require("path");

module.exports = {
  context: __dirname,
  entry: {
    "app": "./src/app.coffee"
  },
  output: {
    path: path.join(__dirname, "dist"),
    filename: "/[name].js"
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee-loader" },
      { test: /\.png$/, loader: "file-loader" },
      { test: /\.less$/,   loader: etx.extract("style-loader","css-loader?minimize!postcss-loader!less-loader")},
      { test: /\.css$/,    loader: etx.extract("style-loader", "css-loader?minimize!") },
    ]
  },
  plugins: [
      new etx("/[name].css", {}),
      new webpack.DefinePlugin({BOXURL: JSON.stringify(process.env.BOXURL)})

  ],
  resolve: { extensions: ["", ".webpack.js", ".web.js", ".js", ".coffee", ".less", ".css"]}
};
