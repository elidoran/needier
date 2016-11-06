assert = require 'assert'
needier = require '../lib'

describe 'test `remove`', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'with non-existent', ->

    describe 'string need', ->

      it 'should return empty removed array', ->
        expected =
          had: 'needs'
          success: true
          removed: {}
        result = this.needs.remove 'A'
        assert.deepEqual result, expected

    describe 'object need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          removed: {}
        result = this.needs.remove id:'A'
        assert.deepEqual result, expected

    describe 'multiple string needs', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          removed: {}
        result = this.needs.remove 'A', 'B'
        assert.deepEqual result, expected

    describe 'multiple object needs', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          removed: {}
        result = this.needs.remove {id:'A'}, {id:'B'}
        assert.deepEqual result, expected

    describe 'string need and then object need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          removed: {}
        result = this.needs.remove 'A', id:'B'
        assert.deepEqual result, expected

    describe 'object need and then string need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          removed: {}
        result = this.needs.remove id:'A', 'B'
        assert.deepEqual result, expected

  describe 'with existent', ->

    describe 'string need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:'A'}
        expected =
          had: 'needs'
          success: true
          removed:
            A:'A'
        result = this.needs.remove 'A'
        assert.deepEqual result, expected

    describe 'object need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:{id:'A'}}
        expected =
          had: 'needs'
          success: true
          removed:
            A:{id:'A'}
        result = this.needs.remove id:'A'
        assert.deepEqual result, expected

    describe 'multiple string needs', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:'A'}
          B:{before:[],after:[],object:'B'}
        expected =
          had: 'needs'
          success: true
          removed:
            A:'A'
            B:'B'
        result = this.needs.remove 'A', 'B'
        assert.deepEqual result, expected

    describe 'multiple object needs', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:{id:'A'}}
          B:{before:[],after:[],object:{id:'B'}}
        expected =
          had: 'needs'
          success: true
          removed:
            A:{id:'A'}
            B:{id:'B'}
        result = this.needs.remove {id:'A'}, {id:'B'}
        assert.deepEqual result, expected

    describe 'string need and then object need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:'A'}
          B:{before:[],after:[],object:{id:'B'}}
        expected =
          had: 'needs'
          success: true
          removed:
            A:'A'
            B:{id:'B'}
        result = this.needs.remove 'A', id:'B'
        assert.deepEqual result, expected

    describe 'object need and then string need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:{id:'A'}}
          B:{before:[],after:[],object:'B'}
        expected =
          had: 'needs'
          success: true
          removed:
            A:{id:'A'}
            B:'B'
        result = this.needs.remove id:'A', 'B'
        assert.deepEqual result, expected
