# extend Array's prototype

unless Array::filter
  Array::filter = (callback) ->
    e for e in this when callback(e)

# merge item into array, by id if given, else use item.id
Array::merge = (item, id=null) ->
  id ||= item.id
  index = i for i, value of this when value.id == id
  if index
    $.extend this[index], item
  else
    item.id = id
    this.push item

