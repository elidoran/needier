assert = require 'assert'
needier = require '../index'

describe 'test `remove`', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'errors', ->

    describe 'with non-existent string need', ->

      it 'should return empty removed array', ->
        expected =
          had: 'needs'
          success: true
          removed: []
          #TODO: should it list the ones which didn't exist??
        result = this.needs.remove 'A'
        assert.deepEqual result, expected
