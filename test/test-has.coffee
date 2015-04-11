assert = require 'assert'
needier = require '../index'

describe 'test `has`', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'errors', ->

    describe 'with non-existent string need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          has: A:false
        result = this.needs.has 'A'
        assert.deepEqual result, expected
