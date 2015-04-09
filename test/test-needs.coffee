assert = require 'assert'
needier = require '../index'

describe 'test acceptable needs', ->
  #before ->
  beforeEach 'new Needs', -> this.needs = needier()

  describe 'test one need without needs', ->

    it 'should be the only need', ->
      expected =
        success: true
        had: 'needs'
        array: [ 'one' ]

      this.needs.of 'one'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test one need with a single need', ->

    it 'should order the dep first', ->
      expected =
        success: true
        had: 'needs'
        array: [ 'one', 'two' ]

      this.needs.of 'two'
        .are 'one'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test a need with two needs', ->

    it 'should order the deps first', ->
      expected =
        success: true
        had: 'needs'
        array: [ 'one', 'two', 'three' ]

      this.needs.of 'three'
        .are 'one', 'two'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test two needs with a need each', ->

    it 'should order the deps first', ->
      expected =
        success: true
        had: 'needs'
        array: [ 'one', 'two', 'three', 'four' ]

      this.needs.of 'two'
        .are 'one'

      this.needs.of 'four'
        .are 'three'

      result = this.needs.ordered()

      assert.deepEqual result, expected

describe 'test cyclical needs', ->
  #before ->
  beforeEach 'new Needs', -> this.needs = needier()

  describe 'test direct cyclical need', ->

    it 'should return error results', ->
      expected =
        had: 'needs'
        error: 'none without need'
        type: 'cyclical'

      this.needs.of 'one'
        .are 'two'

      this.needs.of 'two'
        .are 'one'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test series cyclical need', ->

    it 'should return error results', ->
      expected =
        had: 'needs'
        error: 'none without need'
        type: 'cyclical'

      this.needs.of 'one'
        .are 'two'

      this.needs.of 'two'
        .are 'three'

      this.needs.of 'three'
        .are 'one'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test subneeds cyclical', ->

    it 'should return error results', ->
      expected =
        had: 'needs'
        error: 'cyclical need'
        type: 'cyclical'
        name: 'three'

      this.needs.of 'four'
        .are 'three'

      this.needs.of 'three'
        .are 'two'

      this.needs.of 'two'
        .are 'one'

      this.needs.of 'one'
        .are 'three'

      result = this.needs.ordered()

      assert.deepEqual result, expected

describe 'test needs.a', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'single need without needs', ->

    it 'should return an empty list', ->
      expected =
        success: true
        had: 'needs'
        array: []
      this.needs.of 'A'
      result = this.needs.a 'A'
      assert.deepEqual result, expected

  describe 'single need with single need', ->

    it 'should list it', ->
      expected =
        success: true
        had: 'needs'
        array: [ 'A' ]
      this.needs.of('A').are 'B'
      result = this.needs.a 'B'
      assert.deepEqual result, expected

  describe 'single need with multiple needs', ->

    it 'should list it', ->
      expected =
        success: true
        had: 'needs'
        array: [ 'A' ]
      this.needs.of('A').are 'B', 'C', 'D'
      result1 = this.needs.a 'B'
      result2 = this.needs.a 'C'
      result3 = this.needs.a 'D'
      assert.deepEqual result1, expected
      assert.deepEqual result2.array, expected.array
      assert.deepEqual result3.array, expected.array

  describe 'two needs with same need', ->

    it 'should list both needs', ->
      expected =
        success: true
        had: 'needs'
        array: [ 'A', 'B' ]
      this.needs.of('A').are 'C'
      this.needs.of('B').are 'C'
      result = this.needs.a 'C'
      assert.deepEqual result, expected
