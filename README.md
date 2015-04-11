# needier
[![Build Status](https://travis-ci.org/elidoran/needier.svg?branch=master)](https://travis-ci.org/elidoran/needier)
[![Dependency Status](https://gemnasium.com/elidoran/needier.png)](https://gemnasium.com/elidoran/needier)
[![npm version](https://badge.fury.io/js/needier.svg)](http://badge.fury.io/js/needier)

Dependency ordering

## Install

    npm install needier --save

## Usage

```coffeescript
needs = require('needier')()           # one-step: require and call function

needs.add id:'A', needs:[ 'B', 'C' ]   # A needs both B and C. B+C added as strings

needs.add id:'B', needs:['D']          # B needs D. Replaces string B with object

needs.add id:'C', needs:['E']          # C needs E. Replaces string C with object

result = needs.add id:'D', needs:['C'] # D needs C. Replaces string D with object
# result.added = [ {id:'D', needs:['C']} ]

# all functions can accept IDs as strings or as an 'id' property on an object
# all functions can accept multiple arguments, or an array of arguments
result = needs.has 'B', 'E'
result = needs.has ['B', 'E']          # same as line above
result = needs.has {id:'B'}, {id:'E'}  # same as well
#result.has = { B:true, E:true }

result = needs.of 'A'               # get list of needs for 'A'
#result.needsOf = A:['B', 'C' ]

result = needs.a 'B'                # list what needs 'B'
#result.needsA = B:['A']

console.log needs.ordered().array   # order the needs and get array from results
# prints: [ 'E', 'C', 'D', 'B', 'A' ]

# full ordered() results are:
# { success:true, had:'needs', array: [seen above] }

result = needs.remove 'C'
#result.removed = [ {id:'C', needs:['E']} ]
```

## API of Needs

### **needs.add(object*)**

```coffeescript
results = needs.add 'someStringId', {id:'ObjectID1'}, {id:'ObjectID2', needs:['anotherStringId']}
results = # contents of results from above function call
  success:true
  added:
    someStringId:'someStringId'  # a string becomes both the id and the object
    ObjectID1: { id:'ObjectID1'} # full object, uses its id prop
    ObjectID2: { id:'ObjectID2', needs:['anotherStringId']} # full object uses its id and needs props
    anotherStringId: 'anotherStringId' # implicitly added by ObjectID2
```

### **needs.has(id*)**

Check existence of need(s) with the specified ids.

```coffeescript
# assume it has needs A and B
result = needs.has 'A', 'B', 'C'
needs.has {id:'A'}, {id:'B'}, {id:'C'} # same as above
needs.has ['A', 'B', 'C'] # same as above

result = # results of above calls:
  success:true
  has:
    A:true
    B:true
    C:false

# access results like:
if result.has.A then 'good'
```

### **needs.remove(id*)**

Remove needs (dependencies). An `id` can be a string or an object with an `id`
property.

```coffeescript
needs.add 'A', {id:'B'}, {id:'C', needs:['D']}
# now contains A,B,C,D

result = needs.remove 'A'  # or needs.remove id:'A'  or  needs.remove {id:'A'}
# now contains B,C,D
result = # contents are:
  success:true
  removed:
    A:'A'

result = needs.remove 'C'
# now contains B,D.  'D' remains, added implicitly, remove explicitly. TODO: fix this
result = # contents are:
  success:true
  removed:
    C:{id:'C', needs:['D']}

result = needs.remove 'B', 'D' # or needs.remove ['B', 'D']  or other ID style variations
# now empty
result = # contents are:
  success:true
  removed:
    B:{id:'B'}
    D:'D'
```

### **needs.of(id*)**

Gather needs (dependencies) for all specified id's. An `id` can be a string or an
object with an `id` property.

```coffeescript
# all four lines are equivalent
needs.of 'A', 'B'
needs.of ['A', 'B']
needs.of {id:'A'}, {id:'B'}
needs.of [ {id:'A'}, {id:'B'} ]

result = # result of all the above calls are the same:
  success:true
  needsOf: # we didn't add any needs (deps), so the arrays are empty
    A: []
    B: []
```

### **needs.a(name)**

Gather needs which *need* (depend on) the specified ids.

```coffeescript
needs.add {id:'A', needs:['C']}, {id:'B', needs:['C']}
result = needs.a 'C'
result = # contents are:
  success:true
  needsA: # maps specified need IDs to the objects which needed them
    'C': [{id:'A', needs:['C']}, {id:'B', needs:['C']}]
```

### **needs.ordered()**

Provides all known needs ordered into an array.

Note: This function is the primary reason for this library.

```coffeescript
needs.add {id:'C', needs:['B']}  # can all be passed to add() at once, too
needs.add {id:'D', needs:['C']}
needs.add {id:'B', needs:['A']}
result = needs.ordered()
result = # contents are:
  success:true
  ordered: [ # basically: A, B, C, D. A is a string, added implicityly by B.
    'A', {id:'B', needs:['A']}, {id:'C', needs:['B']}, {id:'D', needs:['C']}
  ]
```

## MIT License
