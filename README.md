# needier
[![Build Status](https://travis-ci.org/elidoran/needier.svg?branch=master)](https://travis-ci.org/elidoran/needier)
[![Dependency Status](https://gemnasium.com/elidoran/needier.png)](https://gemnasium.com/elidoran/needier)
[![npm version](https://badge.fury.io/js/needier.svg)](http://badge.fury.io/js/needier)

Dependency ordering

## Install

    npm install needier --save

## Usage

```coffeescript
needs = require('needier')()         # require and call function

needs.of('A').are 'B', 'C'           # specify A needs both B and C

needs.of('B').are 'D'

needs.of('C').are 'E'

needs.of('D').are 'C'

result = needs.of('A').list()
console.log result.array            # prints: [ 'B', 'C' ]

result = needs.a 'B'
console.log result.array            # prints: [ 'A' ]

console.log needs.ordered().array   # order the needs and get array from results
# prints: [ 'E', 'C', 'D', 'B', 'A' ]

# full ordered() results are:
# { success:true, had:'needs', array: [seen above] }

```

## API of Needs

### **needs.of(name)**

Adds a *Need* and returns that Need with its own functions. See [Need API](#api-of-need)

Used with [need.are(name...)](#needarename) to declare needs (dependencies).

```coffeescript
need = needs.of 'someId'
```

### **needs.ordered()**

Gets an array of all needs ordered by their needs. This is the reason for
creating this library.

```coffeescript
needs.of 'B'
  .are 'A'

needs.of 'E'
  .are 'C', 'D'

needs.of 'C'
  .are 'B'

result = needs.ordered()
console.log result.array
#prints: [ 'A', 'B', 'C', 'D', 'E' ]

```

### **needs.has(name)**

Check existence of a need with the specified name.

### **needs.a(name)**

Get array of need names which need the one specified.

```coffeescript
needs.of 'someId'
  .are 'one'

needs.of 'anotherId'
  .are 'one', 'two'

result = needs.a 'one'
console.log result.array
#prints: [ 'someId', 'anotherId' ]

```

### **needs.remove(name[, name]*)**

Removes all named needs completely. All dependency references to it are removed.

### **needs.clear()**

Removes all added needs.


## API of Need

### **need.are(name[, name]*)**

Add listed names as dependencies of this Need.

```coffeescript
needs.of 'someId'
  .are 'one', 'two', 'three'
```

### **need.list()**

Get array of dependencies for the Need.

```coffeescript
needs.of 'someId'
  .are 'one', 'two', 'three'

result = needs.of('someId').list()
console.log result.array
# prints: [ 'one', 'two', 'three']
```

### **need.remove(name[, name]*)**

Remove named dependencies from the Need.

```coffeescript
needs.of 'someId'
  .are 'one', 'two', 'three'

needs.of('someId').remove 'two'

result = needs.of('someId').list()
console.log result.array
# prints: [ 'one', 'three']
```

## MIT License
