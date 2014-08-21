



############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
# njs_crypto                  = require 'crypto'
#...........................................................................................................
# BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
# TEXT                      = require 'coffeenode-text'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'HOLLERITH/KEY'
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
M                         = options[ 'marks' ]
BNP                       = require 'coffeenode-bitsnpieces'
eq 												= BNP.equals.bind BNP
neq												= ( a, b ) -> not eq a, b
KEY												= require './scratch/KEY'



debug eq ( KEY.new_node 'myrealm', 'mytype', 'myid' ), '$.|myrealm/mytype/myid|'
debug eq ( KEY.new_node 'myrealm', 'mytype', 'myid', 'tail1', 'tail2' ), '$.|myrealm/mytype/myid/tail1/tail2|'

ho||er|t





