const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: [
    'font-awesome/css/font-awesome.css',
    path.join(__dirname, 'index.js'),
  ],
  resolve: {
    extensions: ['.js', '.elm'],
    modules: ['node_modules']
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {}
        }
      },
      {
        test: /\.woff2?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        // Limiting the size of the woff fonts breaks font-awesome ONLY for the extract text plugin
        // loader: "url?limit=10000"
        use: "url-loader"
      },
      {
        test: /\.(ttf|eot|svg)(\?[\s\S]+)?$/,
        use: 'file-loader'
      },
      {
        test: /\.scss$/,
        use: [
          'style-loader',
          'css-loader',
          { loader: 'sass-loader', options: { importLoaders: 1 } },
          'postcss-loader'
        ]
      },
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader',
          'postcss-loader'
        ]
      },
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: 'index.html'
    })
  ],
  output: {
    path: path.join(__dirname, '../priv/static'),
    filename: '[name].[contenthash].js'
  }
};
