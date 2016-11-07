assert = require 'assert'
needier = require '../lib'

describe 'test ordered', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'test ordering strings', ->

    describe 'with a single string', ->

      it 'should return just the one string', ->
        need1 = 'A'
        expected =
          had: 'needs'
          success: true
          array: [need1]
        result = this.needs.add need1
        result = this.needs.ordered()
        assert.deepEqual result, expected

    describe 'with two strings', ->

      it 'should return both strings', ->
        need1 = 'A'
        need2 = 'B'
        expected =
          had: 'needs'
          success: true
          array: [need1, need2]
        result = this.needs.add need1, need2
        result = this.needs.ordered()
        assert.deepEqual result, expected

    describe 'with one string and one object', ->

      it 'should return both both', ->
        need1 = 'A'
        need2 = id:'B'
        expected =
          had: 'needs'
          success: true
          array: [need1, need2]
        result = this.needs.add need1, need2
        result = this.needs.ordered()
        assert.deepEqual result, expected

    describe 'with one string and one object needing the string', ->

      it 'should return both', ->
        need1 = 'A'
        need2 = id:'B', needs:['A']
        expected =
          had: 'needs'
          success: true
          array: [need1, need2]
        result = this.needs.add need1, need2
        result = this.needs.ordered()
        assert.deepEqual result, expected

    describe 'with one string and one object needing the string, flipped', ->

      it 'should return both', ->
        need1 = id:'A', needs:['B']
        need2 = 'B'
        expected =
          had: 'needs'
          success: true
          array: [need2, need1]
        result = this.needs.add need1, need2
        result = this.needs.ordered()
        assert.deepEqual result, expected

  describe 'test ordering objects', ->

    describe 'without sub-objects', ->

      describe 'one object', ->

        it 'should return it', ->
          need1 = id:'A'
          expected =
            had: 'needs'
            success: true
            array: [need1]
          result = this.needs.add need1
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'two objects', ->

        it 'should return them', ->
          need1 = id:'A'
          need2 = id:'B'
          expected =
            had: 'needs'
            success: true
            array: [need1, need2]
          result = this.needs.add need1, need2
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'two objects, flipped', ->

        it 'should return them', ->
          need1 = id:'A'
          need2 = id:'B'
          expected =
            had: 'needs'
            success: true
            array: [need2, need1]
          result = this.needs.add need2, need1
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'object needing other object', ->

        it 'should return needier second', ->
          need1 = id:'A', needs: ['B']
          need2 = id:'B'
          expected =
            had: 'needs'
            success: true
            array: [need2, need1]
          result = this.needs.add need1, need2
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'object needing two other objects', ->

        it 'should return needier second', ->
          need1 = id:'A'
          need2 = id:'B', needs: ['A', 'C']
          need3 = id:'C'
          expected =
            had: 'needs'
            success: true
            array: [need1, need3, need2]
          result = this.needs.add need1, need2, need3
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'two objects needing another object', ->

        it 'should return neediers second', ->
          need1 = id:'A'
          need2 = id:'B', needs:['A']
          need3 = id:'C'
          need4 = id:'D', needs:['C']
          expected =
            had: 'needs'
            success: true
            array: [need1, need2, need3, need4]
          result = this.needs.add need1, need2, need3, need4
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'two objects needing another object, flipped', ->

        it 'should return neediers second', ->
          need1 = id:'A'
          need2 = id:'B', needs:['A']
          need3 = id:'C'
          need4 = id:'D', needs:['C']
          expected =
            had: 'needs'
            success: true
            array: [need1, need2, need3, need4]
          result = this.needs.add need2, need3, need4, need1
          result = this.needs.ordered()
          assert.deepEqual result, expected

    describe 'with sub-objects', ->

      describe 'one object with sub-object', ->

        it 'should return it', ->
          need1 = id:'A', object:some:'thing'
          expected =
            had: 'needs'
            success: true
            array: [some:'thing']
          result = this.needs.add need1
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'two objects with sub-objects', ->

        it 'should return them', ->
          need1 = id:'A', object:some:'thing'
          need2 = id:'B', object:something:'else'
          expected =
            had: 'needs'
            success: true
            array: [{some:'thing'}, {something:'else'}]
          result = this.needs.add need1, need2
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'two objects with sub-objects and needs', ->

        it 'should return them in order', ->
          need1 = id:'A', needs:['B'], object:{some:'thing'}
          need2 = id:'B', object:{something:'else'}
          expected =
            had: 'needs'
            success: true
            array: [{something:'else'}, {some:'thing'}]
          result = this.needs.add need1, need2
          result = this.needs.ordered()
          assert.deepEqual result, expected

      describe 'two objects with sub-objects and needs, flipped', ->

        it 'should return them in order, still', ->
          need1 = id:'A', needs:['B'], object:{some:'thing'}
          need2 = id:'B', object:{something:'else'}
          expected =
            had: 'needs'
            success: true
            array: [{something:'else'}, {some:'thing'}]
          result = this.needs.add need2, need1
          result = this.needs.ordered()
          assert.deepEqual result, expected

  describe 'test cyclical needs', ->

    describe 'test direct cyclical need', ->

      it 'cant need itself', ->
        need1 = id:'A', needs: ['A']
        expected =
          had: 'needs'
          error: 'none without need'
          type: 'cyclical'

        result = this.needs.add need1
        result = this.needs.ordered()

        assert.deepEqual result, expected

      it 'as only objects should return error results', ->
        need1 = id:'A', needs: ['B']
        need2 = id:'B', needs: ['A']
        expected =
          had: 'needs'
          error: 'none without need'
          type: 'cyclical'

        result = this.needs.add need1, need2
        result = this.needs.ordered()

        assert.deepEqual result, expected

      it 'with extra object should return error results', ->
        need1 = id:'A', needs: ['B']
        need2 = id:'B', needs: ['A']
        need3 = id:'C'
        expected =
          had: 'needs'
          error: 'cyclical needs'
          type: 'cyclical'
          needs: [ need1, need2 ]

        result = this.needs.add need1, need2, need3
        result = this.needs.ordered()

        assert.deepEqual result, expected

    describe 'test series cyclical need', ->

      it 'should return error results', ->
        need1 = id:'one', needs: ['two']
        need2 = id:'two', needs: ['three']
        need3 = id:'three', needs:['one']
        expected =
          had: 'needs'
          error: 'none without need'
          type: 'cyclical'

        this.needs.add need1, need2, need3

        result = this.needs.ordered()

        assert.deepEqual result, expected

    describe 'test subneeds cyclical', ->

      it 'should return error results', ->
        need1 = id:'one', needs:['three']
        need2 = id:'two', needs:['one']
        need3 = id:'three', needs:['two']
        need4 = id:'four', needs:['three']
        expected =
          had: 'needs'
          error: 'cyclical need'
          type: 'cyclical'
          name: 'three'

        this.needs.add need1, need2, need3, need4

        result = this.needs.ordered()

        assert.deepEqual result, expected
