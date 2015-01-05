





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
options                   = require '../../options'
M                         = options[ 'marks' ]


###
#===========================================================================================================

888b    888 8888888888 888       888
8888b   888 888        888   o   888
88888b  888 888        888  d8b  888
888Y88b 888 8888888    888 d888b 888
888 Y88b888 888        888d88888b888
888  Y88888 888        88888P Y88888
888   Y8888 888        8888P   Y8888
888    Y888 8888888888 888P     Y888


#===========================================================================================================
###


#-----------------------------------------------------------------------------------------------------------
@new_key = ( schema, theme, topic, predicate, complement, idx... ) ->
  ### TAINT should go to `hollerith/KEY` ###
  unless ( datatype = schema[ predicate ] )?
    throw new Error "unknown datatype #{rpr predicate}"
  #.........................................................................................................
  { 'index-count': index_count, type, pad } = datatype
  #.........................................................................................................
  unless index_count is idx.length
    throw new Error "need #{index_count} indices for predicate #{rpr predicate}, got #{idx.length}"
  #.........................................................................................................
  theme_esc       = KEY.esc theme
  topic_esc       = KEY.esc topic
  predicate_esc   = KEY.esc predicate
  complement_esc  = KEY.esc complement
  ### TAINT parametrize ###
  idxs            = if index_count is 0 then '' else idxs.join ','
  return 's' + '|' + theme_esc + '|' + topic_esc + '|' + predicate_esc + '|' + complement_esc + '|' + idxs



###
#===========================================================================================================

 .d88888b.  888      8888888b.
d88P" "Y88b 888      888  "Y88b
888     888 888      888    888
888     888 888      888    888
888     888 888      888    888
888     888 888      888    888
Y88b. .d88P 888      888  .d88P
 "Y88888P"  88888888 8888888P"


#===========================================================================================================
###


############################################################################################################
# WRITERS
#-----------------------------------------------------------------------------------------------------------
@new_route = ( realm, type, name ) ->
  R = [ realm, type, ]
  R.push name if name?
  return ( @esc part for part in R ).join M[ 'slash' ]

#-----------------------------------------------------------------------------------------------------------
@new_id = ( realm, type, idn ) ->
  slash = M[ 'slash' ]
  return ( @new_route realm, type ) + slash + ( @esc idn )

#-----------------------------------------------------------------------------------------------------------
@new_node = ( realm, type, idn, tail... ) ->
  joiner = M[ 'joiner' ]
  R = M[ 'primary' ] + M[ 'node' ] + joiner + ( @new_id realm, type, idn )
  if tail.length > 0
    R += M[ 'slash' ] + ( ( @esc crumb for crumb in tail ).join M[ 'slash' ] )
  R += joiner
  return R

#-----------------------------------------------------------------------------------------------------------
@new_secondary_node = ( realm, type, idn, tail... ) ->
  joiner  = M[ 'joiner' ]
  slash   = M[ 'slash'  ]
  R = M[ 'secondary' ] + M[ 'node' ] + slash + ( @esc realm ) + ( @esc type )
  if tail.length > 0
    R += joiner + ( ( @esc crumb for crumb in tail ).join slash )
  R += joiner + ( @esc idn ) + joiner
  return R

#-----------------------------------------------------------------------------------------------------------
@new_facet_pair = ( realm, type, idn, name, value, distance = 0 ) ->
  return [
    ( @new_facet            realm, type, idn, name, value, distance ),
    ( @new_secondary_facet  realm, type, idn, name, value, distance ), ]

#-----------------------------------------------------------------------------------------------------------
@new_facet = ( realm, type, idn, name, value, distance = 0 ) ->
  joiner = M[ 'joiner' ]
  return M[ 'primary' ]                     \
    + M[ 'facet' ]                          \
    + joiner                                \
    + ( @new_id realm, type, idn )          \
    + joiner                                \
    + ( @esc name )                         \
    + joiner                                \
    + ( @esc value )                        \
    + joiner                                \
    + distance                              \
    + joiner

#-----------------------------------------------------------------------------------------------------------
@new_secondary_facet = ( realm, type, idn, name, value, distance = 0 ) ->
  joiner = M[ 'joiner' ]
  return M[ 'secondary' ]                   \
    + M[ 'facet' ]                          \
    + joiner                                \
    + ( @new_route realm, type )            \
    + joiner                                \
    + ( @esc name )                         \
    + joiner                                \
    + ( @esc value )                        \
    + joiner                                \
    + ( @esc idn )                          \
    + joiner                                \
    + distance                              \
    + joiner

#-----------------------------------------------------------------------------------------------------------
@new_link_pair = ( realm_0, type_0, idn_0, realm_1, type_1, idn_1, distance = 0 ) ->
  return [
    ( @new_link           realm_0, type_0, idn_0, realm_1, type_1, idn_1, distance ),
    ( @new_secondary_link realm_0, type_0, idn_0, realm_1, type_1, idn_1, distance ), ]

#-----------------------------------------------------------------------------------------------------------
@new_link = ( realm_0, type_0, idn_0, realm_1, type_1, idn_1, distance = 0 ) ->
  joiner = M[ 'joiner' ]
  return M[ 'primary' ]                     \
    + M[ 'link' ]                           \
    + joiner                                \
    + ( @new_id realm_0, type_0, idn_0 )    \
    + joiner                                \
    + ( @new_id realm_1, type_1, idn_1 )    \
    + joiner                                \
    + distance                              \
    + joiner

#-----------------------------------------------------------------------------------------------------------
@new_secondary_link = ( realm_0, type_0, idn_0, realm_1, type_1, idn_1, distance = 0 ) ->
  joiner = M[ 'joiner' ]
  return M[ 'secondary' ]                   \
    + M[ 'link' ]                           \
    + joiner                                \
    + ( @new_route realm_0, type_0 )        \
    + joiner                                \
    + ( @new_id realm_1, type_1, idn_1 )    \
    + joiner                                \
    + ( @esc idn_0 )                        \
    + joiner                                \
    + distance                              \
    + joiner


############################################################################################################
# READERS
#-----------------------------------------------------------------------------------------------------------
@read = ( key ) ->
  [ [ layer, type ], fields... ] = key.split M[ 'joiner' ]
  #.........................................................................................................
  switch layer
    when M[ 'primary' ]
      switch type
        when M[ 'node'  ] then R = @_read_primary_node    fields...
        when M[ 'facet' ] then R = @_read_primary_facet   fields...
        when M[ 'link'  ] then R = @_read_primary_link    fields...
        else throw new Error "unknown type mark #{rpr type}"
    #.......................................................................................................
    when M[ 'secondary' ]
      switch type
        # when M[ 'node'  ] then R = @_read_secondary_node  fields...
        when M[ 'facet' ] then R = @_read_secondary_facet fields...
        when M[ 'link'  ] then R = @_read_secondary_link  fields...
        else throw new Error "unknown type mark #{rpr type}"
    #.......................................................................................................
    else throw new Error "unknown layer mark #{rpr layer}"
  #.........................................................................................................
  R[ 'key' ] = key
  return R

#-----------------------------------------------------------------------------------------------------------
@_read_primary_node = ( id ) ->
  R =
    level:      'primary'
    type:       'node'
    id:         id
  return R

#-----------------------------------------------------------------------------------------------------------
@_read_primary_facet = ( id, name, value, distance ) ->
  R =
    level:      'primary'
    type:       'facet'
    id:         id
    name:       name
    value:      value
    distance:   parseInt distance, 10
  return R

#-----------------------------------------------------------------------------------------------------------
@_read_primary_link = ( id_0, id_1, distance ) ->
  R =
    level:      'primary'
    type:       'link'
    id:         id_0
    target:     id_1
    distance:   parseInt distance, 10
  return R

#-----------------------------------------------------------------------------------------------------------
@_read_secondary_facet = ( route, name, value, idn, distance ) ->
  R =
    level:      'secondary'
    type:       'facet'
    id:         route + M[ 'slash' ] + idn
    name:       name
    value:      value
    distance:   parseInt distance, 10
  return R

#-----------------------------------------------------------------------------------------------------------
@_read_secondary_link = ( route_0, id_1, idn_0, distance ) ->
  id_0 = route_0 + M[ 'slash' ] + idn_0
  R =
    level:      'secondary'
    type:       'link'
    id:         id_0
    target:     id_1
    distance:   parseInt distance, 10
  return R


############################################################################################################
# ANALYZERS
#-----------------------------------------------------------------------------------------------------------
@infer = ( key_0, key_1 ) ->
  return @_infer key_0, key_1, 'primary'

#-----------------------------------------------------------------------------------------------------------
@infer_secondary = ( key_0, key_1 ) ->
  return @_infer key_0, key_1, 'secondary'

#-----------------------------------------------------------------------------------------------------------
@infer_pair = ( key_0, key_1 ) ->
  return @_infer key_0, key_1, 'pair'

#-----------------------------------------------------------------------------------------------------------
@_infer = ( key_0, key_1, mode ) ->
  info_0 = if TYPES.isa_text key_0 then @read key_0 else key_0
  info_1 = if TYPES.isa_text key_1 then @read key_1 else key_1
  #.........................................................................................................
  if ( type_0 = info_0[ 'type' ] ) is 'link'
    #.......................................................................................................
    unless ( id_1 = info_0[ 'target' ] ) is ( id_2 = info_1[ 'id' ] )
      throw new Error "unable to infer link from #{rpr info_0[ 'key' ]} and #{rpr info_1[ 'key' ]}"
    #.......................................................................................................
    switch type_1 = info_1[ 'type' ]
      when 'link'   then return @_infer_link  info_0, info_1, mode
      when 'facet'  then return @_infer_facet info_0, info_1, mode
  #.........................................................................................................
  throw new Error "expected a link plus a link or a facet, got a #{type_0} and a #{type_1}"

#-----------------------------------------------------------------------------------------------------------
@_infer_facet = ( link, facet, mode ) ->
  #.........................................................................................................
  [ link_realm
    link_type
    link_idn  ]   = @split_id link[ 'id' ]
  [ facet_realm
    facet_type
    facet_idn  ]  = @split_id link[ 'id' ]
  ### TAINT route not distinct from ID? ###
  ### TAINT should slashes in name be escaped? ###
  ### TAINT what happens when we infer from an inferred facet? do all the escapes get re-escaped? ###
  ### TAINT use module method ###
  slash           = M[ 'slash' ]
  ### TAINT make use of dash configurable ###
  name            = ( @esc facet_realm ) + '-' + ( @esc facet_type ) + '-' + ( @esc facet[ 'name' ] )
  value           = facet[ 'value'    ]
  distance        =  link[ 'distance' ] + facet[ 'distance' ] + 1
  #.........................................................................................................
  switch mode
    when 'primary'   then return @new_facet           link_realm, link_type, link_idn, name, value, distance
    when 'secondary' then return @new_secondary_facet link_realm, link_type, link_idn, name, value, distance
    when 'pair'      then return @new_facet_pair      link_realm, link_type, link_idn, name, value, distance
    else throw new Error "unknown mode #{rpr mode}"

#-----------------------------------------------------------------------------------------------------------
@_infer_link = ( link_0, link_1, mode ) ->
  ###
    $^|gtfs/stoptime/876|0|gtfs/trip/456
  +                   $^|gtfs/trip/456|0|gtfs/route/777
  ----------------------------------------------------------------
  = $^|gtfs/stoptime/876|1|gtfs/route/777
  = %^|gtfs/stoptime|1|gtfs/route/777|876
  ###
  #.........................................................................................................
  [ realm_0
    type_0
    idn_0  ]  = @split_id link_0[ 'id' ]
  [ realm_2
    type_2
    idn_2  ]  = @split_id link_1[ 'target' ]
  distance    = link_0[ 'distance' ] + link_1[ 'distance' ] + 1
  #.........................................................................................................
  switch mode
    when 'primary'   then return @new_link           realm_0, type_0, idn_0, realm_2, type_2, idn_2, distance
    when 'secondary' then return @new_secondary_link realm_0, type_0, idn_0, realm_2, type_2, idn_2, distance
    when 'pair'      then return @new_link_pair      realm_0, type_0, idn_0, realm_2, type_2, idn_2, distance
    else throw new Error "unknown mode #{rpr mode}"


############################################################################################################
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@esc = do ->
  ### TAINT too complected ###
  #.........................................................................................................
  escape = ( text ) ->
      R = text
      R = R.replace /([-()\[\]{}+?*.$\^|,:#<!\\])/g, '\\$1'
      R = R.replace /\x08/g, '\\x08'
      return R
  #.........................................................................................................
  joiner_matcher  = new RegExp ( escape M[ 'joiner' ] ), 'g'
  # slash_matcher   = new RegExp ( escape M[ 'slash'  ] ), 'g'
  # loop_matcher    = new RegExp ( escape M[ 'loop'   ] ), 'g'
  ### TAINT not correct, could be single digit if byte value < 0x10 ###
  joiner_replacer = ( 'µ' + d.toString 16 for d in new Buffer M[ 'joiner' ] ).join ''
  # slash_replacer  = ( 'µ' + d.toString 16 for d in new Buffer M[ 'slash'  ] ).join ''
  # loop_replacer   = ( 'µ' + d.toString 16 for d in new Buffer M[ 'loop'   ] ).join ''
  #.........................................................................................................
  return ( x ) ->
    throw new Error "value cannot be undefined" if x is undefined
    R = if TYPES.isa_text x then x else rpr x
    R = R.replace /µ/g,           'µb5'
    R = R.replace joiner_matcher, joiner_replacer
    # R = R.replace slash_matcher,  slash_replacer
    # R = R.replace loop_matcher,   loop_replacer
    return R

#-----------------------------------------------------------------------------------------------------------
@unescape = ( text_esc ) ->
  matcher = /µ([0-9a-f]{2})/g
  return text_esc.replace matcher, ( _, cid_hex ) ->
    return String.fromCharCode parseInt cid_hex, 16


#-----------------------------------------------------------------------------------------------------------
@split_id = ( id ) ->
  ### TAINT must unescape ###
  R = id.split slash = M[ 'slash' ]
  throw new Error "expected three parts separated by #{rpr slash}, got #{rpr id}" unless R.length is 3
  throw new Error "realm cannot be empty in #{rpr id}"  unless R[ 0 ].length > 0
  throw new Error "type cannot be empty in #{rpr id}"   unless R[ 1 ].length > 0
  throw new Error "IDN cannot be empty in #{rpr id}"    unless R[ 2 ].length > 0
  return R

#-----------------------------------------------------------------------------------------------------------
@split = ( x ) ->
  return x.split M[ 'joiner' ]

#-----------------------------------------------------------------------------------------------------------
@split_compound_selector = ( compound_selector ) ->
  ### TAINT must unescape ###
  return compound_selector.split M[ 'loop' ]

#-----------------------------------------------------------------------------------------------------------
@_idn_from_id = ( id ) ->
  match = id.replace /^.+?([^\/]+)$/
  throw new Error "not a valid ID: #{rpr id}" unless match?
  return match[ 1 ]

#-----------------------------------------------------------------------------------------------------------
@lte_from_gte = ( gte ) ->
  length  = Buffer.byteLength gte
  R       = new Buffer 1 + length
  R.write gte
  R[ length ] = 0xff
  return R


############################################################################################################
unless module.parent?
  help @new_id                      'gtfs', 'stop', '123'
  # help @new_node                    'gtfs', 'stop', '123'
  help @new_facet                   'gtfs', 'stop', '123', 'name', 1234
  help @new_facet                   'gtfs', 'stop', '123', 'name', 'foo/bar|baz'
  help @new_facet                   'gtfs', 'stop', '123', 'name', 'Bayerischer Platz'
  help @new_secondary_facet         'gtfs', 'stop', '123', 'name', 'Bayerischer Platz'
  help @new_facet_pair              'gtfs', 'stop', '123', 'name', 'Bayerischer Platz'
  help @new_link                    'gtfs', 'stoptime', '456', 'gtfs', 'stop', '123'
  help @new_secondary_link          'gtfs', 'stoptime', '456', 'gtfs', 'stop', '123'
  help @new_link_pair               'gtfs', 'stoptime', '456', 'gtfs', 'stop', '123'
  # help @read @new_node              'gtfs', 'stop', '123'
  help @read @new_facet             'gtfs', 'stop', '123', 'name', 'Bayerischer Platz'
  help @read @new_secondary_facet   'gtfs', 'stop', '123', 'name', 'Bayerischer Platz'
  help @read @new_link              'gtfs', 'stoptime', '456', 'gtfs', 'stop', '123'
  help @read @new_secondary_link    'gtfs', 'stoptime', '456', 'gtfs', 'stop', '123'
  help @infer '$^|gtfs/stoptime/876|0|gtfs/trip/456', '$^|gtfs/trip/456|0|gtfs/route/777'
  help @infer '$^|gtfs/stoptime/876|0|gtfs/trip/456', '%^|gtfs/trip|0|gtfs/route/777|456'
  help @infer '$^|gtfs/trip/456|0|gtfs/stop/123',     '$:|gtfs/stop/123|0|name|Bayerischer Platz'
  help @infer '$^|gtfs/stoptime/876|1|gtfs/stop/123', '$:|gtfs/stop/123|0|name|Bayerischer Platz'


  # levelup = require 'level'
  # REGISTRY  = require '../REGISTRY'
  # db = levelup '/tmp/test.db'#, valueEncoding: 'binary'
  # value = new Buffer 0
  # value = null
  # value = true
  # value = 1
  # db.put 'mykey', value, ( error ) ->
  #   throw error if error?
  # REGISTRY.flush db, ( error ) ->
  #   throw error if error?
  #   db.get 'mykey', ( error, P... ) ->
  #     throw error if error?
  #     info P


