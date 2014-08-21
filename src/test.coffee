



############################################################################################################
# njs_util                  = require 'util'
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
# njs_crypto                  = require 'crypto'
#...........................................................................................................
# BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
TEXT                      = require 'coffeenode-text'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'HOLLERITH/test'
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
eq                        = BNP.equals.bind BNP
neq                       = ( a, b ) -> not eq a, b
KEY                       = require './scratch/KEY'
DIFF                      = require 'coffeenode-diff'

#-----------------------------------------------------------------------------------------------------------
eqs = ( probe, setpoint ) ->
  return if eq probe, setpoint
  log DIFF.colorize probe, setpoint

#-----------------------------------------------------------------------------------------------------------
T = ( title, method ) ->
  arity = method.length
  unless 1 <= arity <= 2
    throw new Error "expected test method with 1 or 2 arguments, got method with #{arity} arguments"
  width       = 30
  title_txt   = TEXT.truncate title
  title_txt   = TEXT.flush_left title_txt, width
  pass_mark   = '◌'
  fail_mark   = '▼'
  _ =
    #.......................................................................................................
    eqs: ( probe, setpoint ) ->
      if eq probe, setpoint
        log TRM.GREEN pass_mark, title_txt, ( TRM.grey setpoint )
      else
        log ( TRM.RED fail_mark, title_txt ), DIFF.colorize probe, setpoint
    #.......................................................................................................
    eqjson: ( probe, setpoint ) ->
      if eq probe, setpoint
        log TRM.GREEN pass_mark, title_txt, ( TRM.grey JSON.stringify setpoint )
      else
        log ( TRM.RED fail_mark, title_txt ), DIFF.colorize ( JSON.stringify probe ), ( JSON.stringify setpoint )
  # whisper title
  method _


T 'KEY.new_node 1',            ( _ ) -> _.eqs ( KEY.new_node            'myrealm', 'mytype', 'myid'                             ), '$.|myrealm/mytype/myid|'
T 'KEY.new_node 2',            ( _ ) -> _.eqs ( KEY.new_node            'myrealm', 'mytype', 'myid', 'tail1', 'tail2'           ), '$.|myrealm/mytype/myid/tail1/tail2|'
T 'KEY.new_facet',             ( _ ) -> _.eqs ( KEY.new_facet           'gtfs', 'stop', '5643', 'name', 'Piazza Bavaria'        ), '$:|gtfs/stop/5643|name|Piazza Bavaria|0|'
T 'KEY.new_secondary_facet',   ( _ ) -> _.eqs ( KEY.new_secondary_facet 'gtfs', 'stop', '5643', 'name', 'Piazza Bavaria'        ), '%:|gtfs/stop|name|Piazza Bavaria|5643|0|'
T 'KEY.new_link',              ( _ ) -> _.eqs ( KEY.new_link            'gtfs', 'stoptime', '77876452', 'gtfs', 'stop', '3221'  ), '$^|gtfs/stoptime/77876452|gtfs/stop/3221|0|'
T 'KEY.new_secondary_link',    ( _ ) -> _.eqs ( KEY.new_secondary_link  'gtfs', 'stoptime', '77876452', 'gtfs', 'stop', '3221'  ), '%^|gtfs/stoptime|gtfs/stop/3221|77876452|0|'

T 'KEY.read node 1',            ( _ ) -> _.eqjson ( KEY.read '$.|myrealm/mytype/myid|'                     ), {"level":"primary","type":"node","id":"myrealm/mytype/myid","key":"$.|myrealm/mytype/myid|"}
T 'KEY.read node 2',            ( _ ) -> _.eqjson ( KEY.read '$.|myrealm/mytype/myid/tail1/tail2|'         ), {"level":"primary","type":"node","id":"myrealm/mytype/myid/tail1/tail2","key":"$.|myrealm/mytype/myid/tail1/tail2|"}
T 'KEY.read facet',             ( _ ) -> _.eqjson ( KEY.read '$:|gtfs/stop/5643|name|Piazza Bavaria|0|'    ), {"level":"primary","type":"facet","id":"gtfs/stop/5643","name":"name","value":"Piazza Bavaria","distance":0,"key":"$:|gtfs/stop/5643|name|Piazza Bavaria|0|"}
T 'KEY.read secondary facet',   ( _ ) -> _.eqjson ( KEY.read '%:|gtfs/stop|name|Piazza Bavaria|5643|0|'    ), {"level":"secondary","type":"facet","id":"gtfs/stop/5643","name":"name","value":"Piazza Bavaria","distance":0,"key":"%:|gtfs/stop|name|Piazza Bavaria|5643|0|"}
T 'KEY.read link',              ( _ ) -> _.eqjson ( KEY.read '$^|gtfs/stoptime/77876452|gtfs/stop/3221|0|' ), {"level":"primary","type":"link","id":"gtfs/stoptime/77876452","target":"gtfs/stop/3221","distance":0,"key":"$^|gtfs/stoptime/77876452|gtfs/stop/3221|0|"}
T 'KEY.read secondary link',    ( _ ) -> _.eqjson ( KEY.read '%^|gtfs/stoptime|gtfs/stop/3221|77876452|0|' ), {"level":"secondary","type":"link","id":"gtfs/stoptime/77876452","target":"gtfs/stop/3221","distance":0,"key":"%^|gtfs/stoptime|gtfs/stop/3221|77876452|0|"}






