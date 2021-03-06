// Generated by CoffeeScript 1.7.1
(function() {
  var TRM, badge, help, njs_path, options, rpr, warn;

  njs_path = require('path');

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = 'timetable/options';

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  module.exports = options = {
    'levelup': {
      'route': njs_path.join(__dirname, './gtfs-db'),
      'new': {
        'keyEncoding': 'utf-8',
        'valueEncoding': 'json'
      }
    },
    'marks': {
      'primary': '$',
      'secondary': '%',
      'loop': '°',
      'joiner': '|',
      'slash': '/',
      'node': '.',
      'link': '^',
      'facet': ':',
      'meta': 'µ'
    }
  };

}).call(this);
