assert = require 'assert'
needier = require '../lib'

describe 'test `has`', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'with non-existent', ->

    describe 'string need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          has: A:false
        result = this.needs.has 'A'
        assert.deepEqual result, expected

    describe 'object need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          has: A:false
        result = this.needs.has id:'A'
        assert.deepEqual result, expected

    describe 'multiple string needs', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          has: A:false, B:false
        result = this.needs.has 'A', 'B'
        assert.deepEqual result, expected

    describe 'multiple object needs', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          has: A:false, B:false
        result = this.needs.has {id:'A'}, {id:'B'}
        assert.deepEqual result, expected

    describe 'string need and then object need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          has: A:false, B:false
        result = this.needs.has 'A', id:'B'
        assert.deepEqual result, expected

    describe 'object need and then string need', ->

      it 'should return false', ->
        expected =
          had: 'needs'
          success: true
          has: A:false, B:false
        result = this.needs.has id:'A', 'B'
        assert.deepEqual result, expected

  describe 'with existent', ->

    describe 'string need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:'A'}
        expected =
          had: 'needs'
          success: true
          has: A:true
        result = this.needs.has 'A'
        assert.deepEqual result, expected

    describe 'object need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:{id:'A'}}
        expected =
          had: 'needs'
          success: true
          has: A:true
        result = this.needs.has id:'A'
        assert.deepEqual result, expected

    describe 'multiple string needs', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:'A'}
          B:{before:[],after:[],object:'B'}
        expected =
          had: 'needs'
          success: true
          has: A:true, B:true
        result = this.needs.has 'A', 'B'
        assert.deepEqual result, expected

    describe 'multiple object needs', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:{id:'A'}}
          B:{before:[],after:[],object:{id:'B'}}
        expected =
          had: 'needs'
          success: true
          has: A:true, B:true
        result = this.needs.has {id:'A'}, {id:'B'}
        assert.deepEqual result, expected

    describe 'string need and then object need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:'A'}
          B:{before:[],after:[],object:{id:'B'}}
        expected =
          had: 'needs'
          success: true
          has: A:true, B:true
        result = this.needs.has 'A', id:'B'
        assert.deepEqual result, expected

    describe 'object need and then string need', ->

      it 'should return true', ->
        this.needs.things =
          A:{before:[],after:[],object:{id:'A'}}
          B:{before:[],after:[],object:'B'}
        expected =
          had: 'needs'
          success: true
          has: A:true, B:true
        result = this.needs.has id:'A', 'B'
        assert.deepEqual result, expected
