had = require('had') id:'needs'

module.exports = () -> new Needs()

class Needs

  constructor: ->
    @clear()

  a: (ids...) ->
    # splatted, will never be null, an empty array instead
    result = @_gather 'before', ids
    success = needsA:result.needs
    success.unknown = result.unknown if result?.unknown?
    return had.success success

  add: (objects...) ->

    if objects?[0]?.push?  #unwrap array
      objects = objects[0]

    added = {}
    for object in objects

      if had.nullArg 'object', object
        #allow error to be added
        continue

      # if they gave us a string then that's both the ID and the object
      if typeof object is 'string'
        id = object

      else if had.nullProp 'id', object
        # let it add the error for later results return
        continue

      else if object?.object?
        id = object.id
        originalObject = object
        object = object.object

      else
        id = object.id

      if @things?[id]?
        if typeof @things[id].object is 'string'
          @things[id].object = object
      else
        @things[id] = before:[], after:[], object:object
        @thingCount++

      added[id] = object

      needs = object?.needs ? originalObject?.needs
      if needs?
        thing = @things[id]
        @_addNeed id, thing, needs, added

    return had.success added:added

  clear: ->
    @things = {}
    @thingCount = 0

  get: (ids...) ->

    if ids?[0]?.push?
      ids = ids[0]  # unwrap array

    get = {}
    unknown = {}
    unknownCount = 0

    if ids.length is 0
      for object in ids

        # passed object with an id prop
        id = if object?.id? then object.id else object

        if @things?[id]?
          get[id] = @things[id]

        else
          unknownCount++
          unknown[id] = object

    else # get all # TODO: deep copy?
      get[key] = value for own key,value of @things

    result = needs:get
    result.unknown = unknown if unknownCount > 0
    had.success result

  has: (ids...) ->

    if ids?[0]?.push?
      ids = ids[0]  # unwrap array

    has = {}

    for id in ids

      # passed object with an id prop
      if id?.id? then id = id.id

      has[id] = @things?[id]?

    had.success has:has

  of: (ids...) ->
    # splatted, will never be null, an empty array instead
    result = @_gather 'after', ids
    success = needsOf:result.needs
    success.unknown = result.unknown if result?.unknown?
    return had.success success

  ordered: () ->

    ids = (id for own id,thing of @things when thing.before.length is 0)
    result = @_search 'after', ids...

    unless result?.error?

      if @thingCount > 0 and result.array.length is 0
        result = had.error
          error: 'none without need'
          type:  'cyclical'

      else
        if @testing then console.log 'PreSwap array:',result.array
        @_swapInThing result.array

    return result

  remove: (ids...) ->
    # splatted, will never be null, an empty array instead

    if ids?[0]?.push? # unwrap array
      ids = ids[0]

    removed = {}

    for id in ids

      # passed object with an id prop
      if id?.id? then id = id.id

      if @things?[id]?
        removed[id] = @things[id].object
        delete @things[id]
        @thingCount--

        for key,thing of @things
          index = thing.before.indexOf id
          thing.before.splice index, 1 if index >= 0

    return had.success removed:removed

  update: (options) ->

    if had.nullArg 'options', options
      return had.results()

    for key in [ 'id', 'needs', 'type' ] # TODO: Had should support this
      if had.nullProp key, options then return had.results

    thing = @things?[options.id]
    unless thing?
      return had.error error:'unknown need', type:'unknown', id:options.id

    switch options.type
      when 'combine'
        added = {}
        @_addNeed options.id, thing, options.needs, added
        return had.success added:added
      else
        return had.error error:'unknown update type', type:'unknown', type:options.type

  _addNeed: (id, thing, needs, added) ->
    for needId in needs
      unless @things?[needId]?
        @add needId
        added[needId] = needId
      other = @things[needId]
      thing.after.push needId unless needId in thing.after
      other.before.push id unless id in other.before

  _gather: (from, ids) ->

    if had.nullArg 'from', from
      return had.results()

    if had.nullArg 'ids', from
      return had.results()

    if ids?[0]?.push? # unwrap array
      ids = ids[0]

    needs = {}
    unknown = {}
    unknownCount = 0

    for object,i in ids

      unless object?
        had.addError error:'null', type:'array element', index:i, in:ids
        continue

      id = if object?.id? then object.id else object # passed object with an id prop

      unless @things?[id]?
        #had.addError error:'unknown need id', type:'invalid request', id:id
        unknownCount++
        unknown[id] = object
        continue

      result = @_search from, id

      unless result?.error?
        index = result.array.indexOf(id)
        result.array.splice index, 1 if index >= 0

        @_swapInThing result.array
        needs[id] = result.array
      # else, add error into return
      else had.addError result # TODO: check this

    result = {}
    result.needs = needs
    result.unknown = unknown if unknownCount > 0
    return had.success result

  _removeNeed: (id, thing, needs) ->
    for needId in needs
      index = thing.after.indexOf needId
      if index > -1 then thing.after = thing.after.splice index, 1
      other = @things[needId]
      if other?
        index = other.before.indexOf id
        if index > -1 then other.before = other.before.splice index, 1

  _search: (which, searchIds...) ->

    search =
      which: which
      result: []
      ing: {}
      ed: {}

    for id in searchIds
      result = @_searchStep search, id

      if result?.error? then break

    unless result?
      result = had.success
        array: search.result

    return result

  _searchStep: (search, searchId) ->

    search.ed[searchId]  = true
    search.ing[searchId] = true

    for id in @things?[searchId][search.which]
      unless search.ed?[id]?
        result = @_searchStep search, id

      else if search.ing?[id]?
        result = had.error
          error: 'cyclical need'
          type: 'cyclical'
          name: id

      if result?.error? then break

    unless result?.error?
      delete search.ing[searchId]

      unless searchId in search.result
        search.result.push searchId

    return result

  _swapInThing: (array) ->
    array[index] = @things[id].object for id,index in array
