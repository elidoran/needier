assert = require 'assert'
needier = require '../index'

describe 'test add needs', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'test one string need without needs', ->

    it 'should be the only need', ->
      need = 'one'
      expected =
        success: true
        had: 'needs'
        added: one:'one'

      result = this.needs.add need

      assert.deepEqual result, expected

  describe 'test one object+id need without needs', ->

    it 'should be the only need', ->
      need = id:'one'
      expected =
        success: true
        had: 'needs'
        added: one:id:'one'

      result = this.needs.add need

      assert.deepEqual result, expected

  describe 'test one object+id+object need without needs', ->

    it 'should be the only need', ->
      need = id:'one', object:{some:'thing'}
      expected =
        success: true
        had: 'needs'
        added: one:need.object

      result = this.needs.add need

      assert.deepEqual result, expected

  describe 'test one need with a single need', ->

    it 'should add them both', ->
      need1 = id:'one'
      need2 = id:'two', needs: ['one']
      expected =
        success: true
        had: 'needs'
        added: one:need1, two:need2

      result = this.needs.add need1, need2

      assert.deepEqual result, expected

  describe 'test one need with a single need', ->

    it 'should order the dep first', ->
      need1 = id:'one'
      need2 = id:'two', needs: ['one']
      expected =
        success: true
        had: 'needs'
        array: [ need1, need2 ]

      this.needs.add need1, need2

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test a need with two needs', ->

    it 'should order the deps first', ->
      need1 = id:'one'
      need2 = id:'two'
      need3 = id:'three', needs: ['one', 'two']
      expected =
        success: true
        had: 'needs'
        array: [ need1, need2, need3 ]

      this.needs.add need1, need2, need3

      result = this.needs.ordered()

      assert.deepEqual result, expected

  describe 'test two needs with a need each', ->

    it 'should order the deps first', ->
      need1 = id:'one'
      need2 = id:'two', needs: ['one']
      need3 = id:'three'
      need4 = id:'four', needs: ['three']
      expected =
        success: true
        had: 'needs'
        array: [ need1, need2, need3, need4 ]

      this.needs.add need1, need2, need3, need4

      result = this.needs.ordered()

      assert.deepEqual result, expected
