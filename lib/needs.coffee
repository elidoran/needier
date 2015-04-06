
module.exports = () -> new Needs()

class Needs

  constructor: ->
    @clear()

  clear: ->
    @nodes = {}
    @nodeCount = 0

  _search: (names, which) ->

    # TODO: check names and which and return error results...

    search =
      which: which
      result: []
      ing: {}
      ed: {}

    for name in names
      result = @_searchStep search, name

      if result?.error? then break

    unless result?
      result =
        array: search.result

    return result

  _searchStep: (search, name) ->

    search.ed[name]  = true
    search.ing[name] = true

    for nodeName in @nodes[name][search.which]

      unless search.ed?[nodeName]?
        result = @_searchStep search, nodeName

      else if search.ing?[nodeName]?
        result =
          error: 'cyclical need'
          type: 'cyclical'
          name: nodeName

      if result?.error? then break


    unless result?.error?
      delete search.ing[name]

      unless name in search.result then search.result.push name

    return result

  remove: (names...) ->
    for name in names when @nodes?[name]?
      delete @nodes[name]
      @nodeCount--
      for node in @nodes
        index = node.before.indexOf name
        node.before.splice index, 1 if index >= 0
    return

  has: (name) -> @nodes?[name]?

  of: (name) ->
    unless @nodes?[name]?

      @nodes[name] = new Needy name, this
      @nodeCount++

    return @nodes[name]

  a: (name) ->
    if name?
      result =
        error: 'specify a need name'
        type: 'param'
        param: 'name'
        value: name # should be null/undefined

    else if @nodes?[name]?
      result = @_search name, 'before'
      unless result?.error?
        idx = result.array.indexOf(name)
        if idx >= 0
          result.array.splice idx, 1

    else
      #throw new Error('Node does not exist: ' + name)
      result =
        error: 'unknown need'
        type: 'param'
        param: 'name'
        value: name

    return result

  ordered: () ->

    # get names of needs to search
    names = (name for own name,node of @nodes when node.before.length is 0)
    result = @_search names, 'after'

    unless result?.error?

      if @nodeCount > 0 and result.array.length is 0
        result =
          error: 'none without need'
          type:  'cyclical'

    return result

class Needy
  constructor: (@name, @needs) ->
    @after = []
    @before = []

  are: (needNames...) ->
    for needName in needNames
      other = @needs.of needName
      @after.push needName unless needName in @after
      other.before.push @name unless @name in other.before
    return this

  list: ->
    result = @needs._search @name, 'after'
    unless result?.error?
      index = result.array.indexOf(@name)
      result.array.splice index, 1 if index >= 0
    return result

  remove: (needNames...) ->
    for needName in needNames
      other = @needs.nodes[needName]
      if other?
        idx = @after.indexOf(needName)
        if idx >= 0
          @after.splice idx, 1
        idx = other.before.indexOf(@name)
        if idx >= 0
          other.before.splice idx, 1
    return
