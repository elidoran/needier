assert = require 'assert'
needier = require '../index'

describe 'test acceptable needs', ->
  #before ->
  beforeEach 'new Needs', -> this.needs = needier()

  describe 'test one need without needs', ->

    it 'should be the only need', ->
      expected =
        array: [ 'one' ]

      this.needs.of 'one'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test one need with a single need', ->

    it 'should order the dep first', ->
      expected =
        array: [ 'one', 'two' ]

      this.needs.of 'two'
        .are 'one'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test a need with two needs', ->

    it 'should order the deps first', ->
      expected =
        array: [ 'one', 'two', 'three' ]

      this.needs.of 'three'
        .are 'one', 'two'

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test two needs with a need each', ->

    it 'should order the deps first', ->
      expected =
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
