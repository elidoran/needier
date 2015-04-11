had = require('had') id:'needs'

module.exports = () -> new Needs()

class Needs

  constructor: ->
    @clear()

  clear: ->
    @things = {}
    @thingCount = 0

  _swapInThing: (array) ->
    array[index] = @things[id].object for id,index in array

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

  has: (ids...) ->

    if ids?[0]?.push?
      ids = ids[0]  # unwrap array

    has = {}

    for id in ids

      # passed object with an id prop
      if id?.id? then id = id.id

      has[id] = @things?[id]?

    had.success has:has

  add: (objects...) ->

    if objects?[0]?.push?  #unwrap array
      objects = objects[0]

    added = {}
    for object in objects

      if had.nullArg 'object', object
        return had.results()

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
        for needId in needs
          unless @things?[needId]?
            @add needId
            added[needId] = needId
          other = @things[needId]
          unless needId in thing.after
            thing.after.push needId
          unless id in other.before
            other.before.push id

    return had.success added:added

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

  _get: (from, ids) ->

    if had.nullArg 'from', from
      return had.results()

    if had.nullArg 'ids', from
      return had.results()

    if ids?[0]?.push? # unwrap array
      ids = ids[0]

    hold = {}

    for id,i in ids

      unless id?
        had.addError error:'null', type:'array element', index:i, in:ids
        continue

      if id?.id? # passed object with an id prop
        id = id.id

      unless @things?[id]?
        had.addError error:'unknown need id', type:'invalid request', id:id
        continue

      result = @_search from, id

      unless result?.error?
        index = result.array.indexOf(id)
        result.array.splice index, 1 if index >= 0

        @_swapInThing result.array

        hold[id] = result.array
      # else, add error into return
      else had.addError result # TODO: check this

    return hold

  of: (ids...) ->
    # splatted, will never be null, an empty array instead
    hold = @_get 'after', ids
    return had.success needsOf:hold

  a: (ids...) ->
    # splatted, will never be null, an empty array instead
    hold = @_get 'before', ids
    return had.success needsA:hold

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
