const merge = require('webpack-merge');
const environment = require('./environment');

const config = environment.toWebpackConfig();

const additionalConfig = {

};

module.exports = merge(config, additionalConfig);