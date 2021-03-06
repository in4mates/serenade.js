isArrayIndex = (index) -> "#{index}".match(/^\d+$/)

class Collection
  defineEvent @prototype, "change"

  def @prototype, "first", get: ->
    @[0]

  def @prototype, "last", get: ->
    @[@length-1]

  constructor: (list=[]) ->
    @[index] = val for val, index in list
    @length = list?.length or 0

  get: (index) ->
    @[index]

  set: (index, value) ->
    @[index] = value
    @length = Math.max(@length, index + 1) if isArrayIndex(index)
    value

  update: (list) ->
    delete @[index] for index, _ of @ when isArrayIndex(index)
    @[index] = val for val, index in list
    @length = list?.length or 0
    list

  sortBy: (attribute) ->
    @sort((a, b) -> if a[attribute] < b[attribute] then -1 else 1)

  includes: (item) ->
    @indexOf(item) >= 0

  find: (fun) ->
    return item for item in @ when fun(item)

  insertAt: (index, value) ->
    Array::splice.call(@, index, 0, value)
    value

  deleteAt: (index) ->
    value = @[index]
    Array::splice.call(@, index, 1)
    value

  delete: (item) ->
    index = @indexOf(item)
    @deleteAt(index) if index isnt -1

  concat: (args...) ->
    args = for arg in args
      if arg instanceof Collection then arg.toArray() else arg
    new Collection(@toArray().concat(args...))

  toArray: ->
    array = []
    array[index] = val for index, val of @ when isArrayIndex(index)
    array

  clone: ->
    new Collection(@toArray())

  toString: ->
    @toArray().toString()

  toLocaleString: ->
    @toArray().toLocaleString()

  toJSON: ->
    serializeObject(@toArray())

  Object.getOwnPropertyNames(Array.prototype).forEach (fun) =>
    this::[fun] or= Array::[fun]

  ["splice", "map", "filter", "slice"].forEach (fun) =>
    original = this::[fun]
    this::[fun] = ->
      new Collection(original.apply(@, arguments))

  ["push", "pop", "unshift", "shift", "splice", "sort", "reverse", "update", "set", "insertAt", "deleteAt"].forEach (fun) =>
    original = this::[fun]
    this::[fun] = ->
      old = @clone()
      val = original.apply(@, arguments)
      @change.trigger(old, @)
      val
