



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
#...........................................................................................................
P                         = require 'pipedreams'
# pimp_stream               = P.create_readstream.pimp
$                         = P.$.bind P

#-----------------------------------------------------------------------------------------------------------
eqs = ( probe, setpoint ) ->
  return if eq probe, setpoint
  log DIFF.colorize probe, setpoint

#-----------------------------------------------------------------------------------------------------------
T = ( title, method ) ->
  arity         = method.length
  unless 1 <= arity <= 2
    throw new Error "expected test method with 1 or 2 arguments, got method with #{arity} arguments"
  T.error_count = 0
  title_width   = 30
  message_width = 70
  title_txt     = TEXT.flush_left ( TEXT.truncate title, title_width ), title_width
  pass_mark     = '◌'
  fail_mark     = '▼'
  _ =
    #.......................................................................................................
    eqs: ( probe, setpoint ) ->
      if eq probe, setpoint
        log TRM.GREEN pass_mark, title_txt, ( TRM.grey TEXT.truncate setpoint, message_width )
      else
        T.error_count += 1
        log ( TRM.RED fail_mark, title_txt ), DIFF.colorize probe, setpoint
    #.......................................................................................................
    eqjson: ( probe, setpoint ) ->
      if eq probe, setpoint
        log TRM.GREEN pass_mark, title_txt, ( TRM.grey TEXT.truncate ( JSON.stringify setpoint ), message_width )
      else
        T.error_count += 1
        log ( TRM.RED fail_mark, title_txt ), DIFF.colorize ( JSON.stringify probe ), ( JSON.stringify setpoint )
  # whisper title
  method _


T 'KEY.new_node 1',                   ( _ ) -> _.eqs ( KEY.new_node            'myrealm', 'mytype', 'myid'                             ), '$.|myrealm/mytype/myid|'
T 'KEY.new_node 2',                   ( _ ) -> _.eqs ( KEY.new_node            'myrealm', 'mytype', 'myid', 'tail1', 'tail2'           ), '$.|myrealm/mytype/myid/tail1/tail2|'
T 'KEY.new_facet',                    ( _ ) -> _.eqs ( KEY.new_facet           'gtfs', 'stop', '5643', 'name', 'Piazza Bavaria'        ), '$:|gtfs/stop/5643|name|Piazza Bavaria|0|'
T 'KEY.new_secondary_facet',          ( _ ) -> _.eqs ( KEY.new_secondary_facet 'gtfs', 'stop', '5643', 'name', 'Piazza Bavaria'        ), '%:|gtfs/stop|name|Piazza Bavaria|5643|0|'
T 'KEY.new_link',                     ( _ ) -> _.eqs ( KEY.new_link            'gtfs', 'stoptime', '77876452', 'gtfs', 'stop', '3221'  ), '$^|gtfs/stoptime/77876452|gtfs/stop/3221|0|'
T 'KEY.new_secondary_link',           ( _ ) -> _.eqs ( KEY.new_secondary_link  'gtfs', 'stoptime', '77876452', 'gtfs', 'stop', '3221'  ), '%^|gtfs/stoptime|gtfs/stop/3221|77876452|0|'

T 'KEY.read node 1',                  ( _ ) -> _.eqjson ( KEY.read '$.|myrealm/mytype/myid|'                     ), {"level":"primary","type":"node","id":"myrealm/mytype/myid","key":"$.|myrealm/mytype/myid|"}
T 'KEY.read node 2',                  ( _ ) -> _.eqjson ( KEY.read '$.|myrealm/mytype/myid/tail1/tail2|'         ), {"level":"primary","type":"node","id":"myrealm/mytype/myid/tail1/tail2","key":"$.|myrealm/mytype/myid/tail1/tail2|"}
T 'KEY.read facet',                   ( _ ) -> _.eqjson ( KEY.read '$:|gtfs/stop/5643|name|Piazza Bavaria|0|'    ), {"level":"primary","type":"facet","id":"gtfs/stop/5643","name":"name","value":"Piazza Bavaria","distance":0,"key":"$:|gtfs/stop/5643|name|Piazza Bavaria|0|"}
T 'KEY.read secondary facet',         ( _ ) -> _.eqjson ( KEY.read '%:|gtfs/stop|name|Piazza Bavaria|5643|0|'    ), {"level":"secondary","type":"facet","id":"gtfs/stop/5643","name":"name","value":"Piazza Bavaria","distance":0,"key":"%:|gtfs/stop|name|Piazza Bavaria|5643|0|"}
T 'KEY.read link',                    ( _ ) -> _.eqjson ( KEY.read '$^|gtfs/stoptime/77876452|gtfs/stop/3221|0|' ), {"level":"primary","type":"link","id":"gtfs/stoptime/77876452","target":"gtfs/stop/3221","distance":0,"key":"$^|gtfs/stoptime/77876452|gtfs/stop/3221|0|"}
T 'KEY.read secondary link',          ( _ ) -> _.eqjson ( KEY.read '%^|gtfs/stoptime|gtfs/stop/3221|77876452|0|' ), {"level":"secondary","type":"link","id":"gtfs/stoptime/77876452","target":"gtfs/stop/3221","distance":0,"key":"%^|gtfs/stoptime|gtfs/stop/3221|77876452|0|"}

T 'KEY.infer from links',             ( _ ) -> _.eqjson ( KEY.infer           '%^|gtfs/stoptime|gtfs/trip/443|77876452|0|', '%^|gtfs/trip|gtfs/route/89|443|0|' ), "$^|gtfs/stoptime/77876452|gtfs/route/89|1|"
T 'KEY.infer_secondary from links',   ( _ ) -> _.eqjson ( KEY.infer_secondary '%^|gtfs/stoptime|gtfs/trip/443|77876452|0|', '%^|gtfs/trip|gtfs/route/89|443|0|' ), "%^|gtfs/stoptime|gtfs/route/89|77876452|1|"
T 'KEY.infer_pair from links',        ( _ ) -> _.eqjson ( KEY.infer_pair      '%^|gtfs/stoptime|gtfs/trip/443|77876452|0|', '%^|gtfs/trip|gtfs/route/89|443|0|' ), ["$^|gtfs/stoptime/77876452|gtfs/route/89|1|","%^|gtfs/stoptime|gtfs/route/89|77876452|1|"]

T 'KEY.infer link, facet',            ( _ ) -> _.eqjson ( KEY.infer           '%^|gtfs/stoptime|gtfs/trip/443|77876452|0|', '$:|gtfs/trip/443|headsign|Pankow|0|' ), "$:|gtfs/stoptime/77876452|gtfs-stoptime-headsign|Pankow|1|"
T 'KEY.infer_secondary link, facet',  ( _ ) -> _.eqjson ( KEY.infer_secondary '%^|gtfs/stoptime|gtfs/trip/443|77876452|0|', '$:|gtfs/trip/443|headsign|Pankow|0|' ), "%:|gtfs/stoptime|gtfs-stoptime-headsign|Pankow|77876452|1|"
T 'KEY.infer_pair link, facet',       ( _ ) -> _.eqjson ( KEY.infer_pair      '%^|gtfs/stoptime|gtfs/trip/443|77876452|0|', '$:|gtfs/trip/443|headsign|Pankow|0|' ), ["$:|gtfs/stoptime/77876452|gtfs-stoptime-headsign|Pankow|1|","%:|gtfs/stoptime|gtfs-stoptime-headsign|Pankow|77876452|1|"]

# T.done()

if T.error_count > 0
  whisper()
  whisper "in diffs, parts that are missing (but should be there) are shown in", TRM.RED    'red'
  whisper "and       parts that should be there (but are missing) are shown in", TRM.GREEN  'green'
  whisper()
  process.exit 1



db = ( require 'level' ) '/tmp/foodb'
# db.put (new Buffer [ 0xff ] ), (new Buffer [ 0xff ] ), ( error, result ) ->
db.put '􏿽', '􏿽', ( error, result ) ->
  throw error if error?
  db.createReadStream keyEncoding: 'binary'
    .pipe P.$show()

keys = [
  [0x61]
  [0x62]
  [0x63]
  [0xc3,0xa4]
  [0xc3,0xbf]
  [0xce,0x98]
  [0xe4,0xb8,0xad]
  [0xf0,0xa0,0x80,0x80]
  [0xf4,0x8f,0xbf,0xbd,]
  [0xff,]
  ]
for key in keys
  debug ( byte.toString 2 for byte in key )


