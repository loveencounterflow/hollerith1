






############################################################################################################
# njs_fs                    = require 'fs'
#...........................................................................................................
# TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'HOLLERITH/main'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
urge                      = TRM.get_logger 'urge',      badge
echo                      = TRM.echo.bind TRM
rainbow                   = TRM.rainbow.bind TRM
#...........................................................................................................
options                   = require '../options'
indexes                   = options[ 'data' ][ 'indexes' ]
new_db                    = require 'level'
#...........................................................................................................
ASYNC                     = require 'async'
#...........................................................................................................
P                         = require 'pipedreams'
# pimp_stream               = P.create_readstream.pimp
$                         = P.$.bind P
KEY                       = require './KEY'



############################################################################################################
unless module.parent?
  urge 'HOLLERITH'


