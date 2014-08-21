


############################################################################################################
njs_fs                    = require 'fs'
#...........................................................................................................
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'TIMETABLE/REGISTRY'
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




#-----------------------------------------------------------------------------------------------------------
test_folder_exists = ( route ) ->
  return false unless njs_fs.existsSync route
  is_folder = ( njs_fs.statSync route ).isDirectory()
  throw new Error "route exists but is not a folder: #{route}" unless is_folder
  return true

#-----------------------------------------------------------------------------------------------------------
@new_registry = ( route ) ->
  route ?= options[ 'levelup' ][ 'route' ]
  return new_db route, options[ 'levelup' ][ 'new' ]

#-----------------------------------------------------------------------------------------------------------
@_new_registry = ( route ) ->
  route        ?= options[ 'levelup' ][ 'route' ]
  folder_exists = test_folder_exists route
  registry      = @new_registry route
  return [ folder_exists, registry, ]

#-----------------------------------------------------------------------------------------------------------
@close = ( registry, handler ) ->
  registry.close ( error ) =>
    help 'registry closed'
    handler error

#-----------------------------------------------------------------------------------------------------------
@flush = ( registry, handler ) ->
  registry.close ( error ) =>
    return handler error if error?
    registry.open ( error ) =>
      help 'registry flushed'
      handler error, registry

#-----------------------------------------------------------------------------------------------------------
@register = ( registry, record, handler ) ->
  id = record[ 'id' ]
  unless id?
    throw new Error """
      unable to register record without ID:
      #{rpr record}"""
  ### Records whose only attribute is the ID field are replaced by `1`: ###
  value = if ( Object.keys record ).length is 1 then 1 else record
  registry.put id, value, ( error ) =>
    return handler error if error?
    handler null, record

#-----------------------------------------------------------------------------------------------------------
@$register = ( registry ) ->
  return $ ( record, handler ) =>
    @register registry, record, ( error ) =>
      return handler error if error?
      handler null, record

#-----------------------------------------------------------------------------------------------------------
@register_2 = ( registry, record, handler ) ->
  ### TAINT kludge, change to using strings as records ###
  id = record[ 'id' ]
  unless id?
    throw new Error """
      unable to register record without ID:
      #{rpr record}"""
  #.........................................................................................................
  meta_value            = '1'
  entries               = []
  ### TAINT kludge, must be changed in GTFS reader ###
  [ realm, type, idn, ] = id.split '/'
  route                 = KEY.new_route realm, type
  key                   = KEY.new_node  realm, type, idn
  entries.push [ key, JSON.stringify record, ]
  #.........................................................................................................
  for name, value of record
    ### TAINT make configurable ###
    continue if name is 'id'
    continue if name is 'gtfs-id'
    continue if name is 'gtfs-type'
    facet_route = KEY.new_route realm, type, name
    #.....................................................................................................
    if ( has_index = indexes[ 'direct' ]?[ 'facet' ] )?
      has_primary   = has_index[ 'primary'   ]?[ facet_route ] ? false
      has_secondary = has_index[ 'secondary' ]?[ facet_route ] ? false
      if has_primary or has_secondary
        if has_primary
          key = KEY.new_facet           realm, type, idn, name, value
          entries.push [ key, meta_value, ]
        if has_secondary
          key = KEY.new_secondary_facet realm, type, idn, name, value
          entries.push [ key, meta_value, ]
    #.....................................................................................................
    if ( has_index = indexes[ 'direct' ]?[ 'link' ] )?
      has_primary   = has_index[ 'primary'   ]?[ facet_route ] ? false
      has_secondary = has_index[ 'secondary' ]?[ facet_route ] ? false
      if has_primary or has_secondary
        ### TAINT inefficiently first splitting, then joining ###
        id_1                        = value
        [ realm_1, type_1, idn_1, ] = KEY.split_id id_1
        if has_primary
          key = KEY.new_link           realm, type, idn, realm_1, type_1, idn_1, 0
          entries.push [ key, meta_value, ]
        if has_secondary
          key = KEY.new_secondary_link realm, type, idn, realm_1, type_1, idn_1, 0
          entries.push [ key, meta_value, ]
  #.........................................................................................................
  tasks = ( { type: 'put', key: key, value: value } for [ key, value, ] in entries )
  registry.batch tasks, ( error ) =>
    handler if error? then error else null

#-----------------------------------------------------------------------------------------------------------
@$register_2 = ( registry ) ->
  return $ ( record, handler ) =>
    @register_2 registry, record, ( error ) =>
      return handler error if error?
      handler null, record

#-----------------------------------------------------------------------------------------------------------
@$count = ( registry, realm, type ) ->
  count = 0
  #.........................................................................................................
  on_data = ( record ) ->
    count += 1
    @emit 'data', record
  #.........................................................................................................
  on_end = ( record ) ->
    key = KEY.new_node 'µ', realm, type, 'count'
    # emit  = @emit.bind @
    registry.put key, count, ( error ) =>
      return @emit 'error', error if error?
      @emit 'end'
  #.........................................................................................................
  return P.through on_data, on_end


#===========================================================================================================
# INFERRED PROPERTIES
#-----------------------------------------------------------------------------------------------------------
@register_inferred_properties = ( registry, handler ) ->
  count = 0
  for entry_type, type_index of indexes[ 'inferred' ]
    for level, level_index of type_index
      for compound_selector in level_index
        [ source_selector
          target_facet_names... ] = KEY.split_compound_selector compound_selector
        unless target_facet_names.length is 1
          warn "multiple target names are not yet implemented"
          continue
        target_facet_name = target_facet_names[ 0 ]
        [ realm, type, ]  = KEY.split_id ( KEY.read source_selector )[ 'id' ]
        count_key = KEY.new_node 'µ', realm, type, 'count'
        registry.get count_key, ( error, count ) =>
          return handler error if error?
          debug count_key, count
          input = @_rdp_key_stream_from_prefix registry, source_selector
          P.pimp_readstream input, count, "#{realm}/#{type}|"
            .pipe @$_rdp_proxy_from_source()
            .pipe @$_rdp_add_target_key level, entry_type, target_facet_name
            .pipe P.$pick 'target-key'
            .pipe $ ( target_key, handler ) -> handler null, key: target_key, value: '1'
            .pipe P.duplex registry.createWriteStream(), input
            # .pipe P.$sample 1 / 1e3
            # .pipe P.$show()
            .on 'end', -> return handler null

#-----------------------------------------------------------------------------------------------------------
### TAINT code duplication ###
### TAINT wrong place for method ###
@_rdp_read_stream_from_prefix = ( registry, prefix ) ->
  query =
    gte:      prefix
    lte:      KEY.lte_from_gte prefix
  return registry.createReadStream query

#-----------------------------------------------------------------------------------------------------------
@_rdp_key_stream_from_prefix = ( registry, prefix ) ->
  query =
    gte:      prefix
    lte:      KEY.lte_from_gte prefix
  return registry.createKeyStream query

#-----------------------------------------------------------------------------------------------------------
@_rdp_value_stream_from_prefix = ( registry, prefix ) ->
  query =
    gte:      prefix
    lte:      KEY.lte_from_gte prefix
  return registry.createValueStream query

#-----------------------------------------------------------------------------------------------------------
@$_rdp_proxy_from_source = ->
  return $ ( source_key, handler ) =>
    ### TAINT specific to links ###
    Z =
      'source-entry':     source_entry = KEY.read source_key
      'source-node-id':   source_entry[ 'id' ]
      'proxy-node-id':    source_entry[ 'target' ]
    ### TAINT inefficiently splitting and joining key ###
    [ Z[ 'source-realm' ]
      Z[ 'source-type'  ]
      Z[ 'source-idn'   ] ] = KEY.split_id Z[ 'source-node-id' ]
    ### TAINT inefficiently splitting and joining key ###
    [ Z[ 'proxy-realm'  ]
      Z[ 'proxy-type'   ]
      Z[ 'proxy-idn'    ] ] = KEY.split_id Z[ 'proxy-node-id' ]
    Z[ 'proxy-node-key' ]   = KEY.new_node Z[ 'proxy-realm' ], Z[ 'proxy-type' ], Z[ 'proxy-idn' ]
    #.......................................................................................................
    registry.get Z[ 'proxy-node-key' ], ( error, proxy_node ) =>
      return handler error if error?
      ### TAINT why is this not done automatically? ###
      Z[ 'proxy-node' ] = JSON.parse proxy_node
      handler null, Z

#-----------------------------------------------------------------------------------------------------------
@$_rdp_add_target_key = ( level, entry_type, target_facet_name ) ->
  return $ ( proxy_info, handler ) =>
    proxy_node    = proxy_info[ 'proxy-node' ]
    target_value  = proxy_node[ target_facet_name ]
    ### TAINT kludge ###
    unless target_value?
      return handler new Error "facet #{rpr target_facet_name} not defined in #{rpr target_node}"
    # help  rpr source_entry
    # debug rpr proxy_node
    # proxy_info  target_facet_name, target_value
    # proxy_info  source_realm, source_type, source_idn
    #.......................................................................................................
    switch level
      when 'secondary'
        switch entry_type
          when 'link'
            ### TAINT inefficiently splitting and joining key ###
            [ target_realm
              target_type
              target_idn  ] = KEY.split_id target_value
            distance        = proxy_info[ 'source-entry' ][ 'distance' ] + 1
            target_key      = KEY.new_secondary_link  proxy_info[ 'source-realm'  ],
                                                      proxy_info[ 'source-type'   ],
                                                      proxy_info[ 'source-idn'    ],
                                                      target_realm,
                                                      target_type,
                                                      target_idn,
                                                      distance
            # registry.put key, '1', ( error ) =>
            #   return handler error if error?
            #   whisper count if count % 1000 is 0
            #   count += 1
          else
            return handler new Error "not implemented"
      else
        return handler new Error "not implemented"
    #.......................................................................................................
    proxy_info[ 'target-key' ] = target_key
    handler null, proxy_info

# #-----------------------------------------------------------------------------------------------------------
# f = ->
#   x
#   .on 'data', ( source_key ) =>
#     # [ target_realm, target_type, target_idn ] = KEY.split_id ( KEY.read source_key )[ 'target' ]
#     # target_node_key = KEY.new_node target_realm, target_type, target_idn
#       # registry.put
#   .on 'error', ( error ) -> return handler error
#   .on 'end', -> return handler null




############################################################################################################
unless module.parent?
  registry = @new_registry()
  @register_inferred_properties registry, ( error, data ) ->
    throw error if error?
    help data

