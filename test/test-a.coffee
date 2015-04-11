assert = require 'assert'
needier = require '../index'

describe 'test needs.a', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'single need without needs', ->

    describe 'test need ID is an object with id', ->

      it 'should return an empty list', ->
        need1 = id:'A'
        expected =
          success: true
          had: 'needs'
          needsA: A:[]
        result = this.needs.add need1
        result = this.needs.a id:'A'
        assert.deepEqual result, expected

    describe 'test need ID is a string', ->

      it 'should return an empty list', ->
        need1 = id:'A'
        expected =
          success: true
          had: 'needs'
          needsA: A:[]
        result = this.needs.add need1
        result = this.needs.a 'A'
        assert.deepEqual result, expected

  describe 'single need with single need', ->

    it 'should list it', ->
      need2 = id:'B', needs:['A']
      expected =
        success: true
        had: 'needs'
        needsA: A:[ need2 ]
      result = this.needs.add need2#need1, need2
      result = this.needs.a id:'A'
      assert.deepEqual result, expected

  describe 'single need with multiple needs, implicit', ->

    it 'should list it', ->
      need1 = id:'A', needs:['B', 'C', 'D']
      expected =
        success: true
        had: 'needs'
        needsA: B:[ need1 ]
      this.needs.add need1#, need2, need3, need4
      result1 = this.needs.a id:'B'
      result2 = this.needs.a id:'C'
      result3 = this.needs.a id:'D'
      assert.deepEqual result1, expected
      assert.deepEqual result2.needsA.C, expected.needsA.B
      assert.deepEqual result3.needsA.D, expected.needsA.B

  describe 'single need with multiple needs, explicit', ->

    it 'should list it', ->
      need1 = id:'A', needs:['B', 'C', 'D']
      need2 = id:'B'
      need3 = id:'C'
      need4 = id:'D'
      expected =
        success: true
        had: 'needs'
        needsA: B:[ need1 ]
      this.needs.add need1, need2, need3, need4
      result1 = this.needs.a id:'B'
      result2 = this.needs.a id:'C'
      result3 = this.needs.a id:'D'
      assert.deepEqual result1, expected
      assert.deepEqual result2.needsA.C, expected.needsA.B
      assert.deepEqual result3.needsA.D, expected.needsA.B

  describe 'two needs with same need, implicit', ->

    it 'should list both needs', ->
      need1 = id:'A', needs:['C']
      need2 = id:'B', needs:['C']
      expected =
        success: true
        had: 'needs'
        needsA: C:[ need1, need2 ]
      this.needs.add need1, need2
      result = this.needs.a id:'C'
      assert.deepEqual result, expected

  describe 'two needs with same need, explicit', ->

    it 'should list both needs', ->
      need1 = id:'A', needs:['C']
      need2 = id:'B', needs:['C']
      need3 = id:'C'
      expected =
        success: true
        had: 'needs'
        needsA: C:[ need1, need2 ]
      this.needs.add need1, need2#, need3
      result = this.needs.a id:'C'
      assert.deepEqual result, expected
