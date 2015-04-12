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

### **needs.add(object+)**

```coffeescript
need1 = 'someStringId'  # a string, will be both id and object
need2 = id:'ObjectId1'  # an object with `id` property
need3 = id:'ObjectId2', needs:[ 'anotherStringId' ] # object with id and needs

results = needs.add need1, need2, need3
results = # contents are:
  success:true
  added:
    someStringId:'someStringId'  # string
    ObjectID1: { id:'ObjectID1'} # full object
    ObjectID2: { id:'ObjectID2', needs:['anotherStringId']} props
    anotherStringId: 'anotherStringId' # implicitly added by ObjectID2
```

### **needs.include(id, needs+)**

Add needs (dependencies) to an existing need.

```coffeescript

needs.add id:'A', needs:['B']

# three equivalent calls
#  id can be a string or an object with an id property
#  needs can be a list of arguments or an array
needs.include 'A', 'C'
needs.include {id:'A'}, 'C'
needs.include 'A', ['C']

result = needs.of 'A'
results = # contents are:
  success:true
  needsOf: A:['B', 'C']
```

### **needs.has(id+)**

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

### **needs.remove(id+)**

Remove needs (dependencies). An `id` can be a string or an object with an `id`
property.

```coffeescript
needs.add 'A', {id:'B'}, {id:'C', needs:['D']}
# now contains A,B,C,D

result = needs.remove 'A'  
needs.remove id:'A'   # same
needs.remove {id:'A'} # same
# now contains B,C,D
result = # contents are:
  success:true
  removed:
    A:'A'

result = needs.remove 'C'
# now contains B,D.
# NOTE: D remains, added implicitly, remove explicitly. TODO: fix this
result = # contents are:
  success:true
  removed:
    C:{id:'C', needs:['D']}

result = needs.remove 'B', 'D'
needs.remove ['B', 'D']  #all alternates allowed
# now empty
result = # contents are:
  success:true
  removed:
    B:{id:'B'}
    D:'D'
```

### **needs.retract(id, needs+)**

Removes needs (dependencies) from an existing need.

```coffeescript

needs.add id:'A', needs:['B', 'C']

# three equivalent calls
#  id can be a string or an object with an id property
#  needs can be a list of arguments or an array
needs.retract 'A', 'C'
needs.retract 'A', ['C']
needs.retract {id:'A'}, ['C']

result = needs.of 'A'
results = # contents are:
  success:true
  needsOf: A:['B']
```

### **needs.replace(id, needs+)**

Replaces existing needs (dependencies) of an existing need.

```coffeescript

needs.add id:'A', needs:['B', 'C']

# three equivalent calls
#  id can be a string or an object with an id property
#  needs can be a list of arguments or an array
needs.replace 'A', 'D', 'E'
needs.replace {id:'A'}, 'D', 'E'
needs.replace 'A', ['D', 'E']

result = needs.of 'A'
results = # contents are:
  success:true
  needsOf: A:['D', 'E']
```

### **needs.of(id+)**

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

### **needs.a(id+)**

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

## Todo

1. add tests for `get`
2. add before/after constraints instead of `needs` (which is essentially a `after` constraint)
3. add tests for before/after
4. add tests for include/retract/replace

## MIT License
