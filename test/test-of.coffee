assert = require 'assert'
needier = require '../index'

describe 'test `of`', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'errors', ->

    describe 'with non-existent string need', ->

      it 'should return error', ->
        expected =
          had: 'needs'
          success: true
          successes: [
            {had:'needs',needsOf:{}, success:true}
          ]
          error:'multiple'
          errors:[
            {error:'unknown need id',type:'invalid request',id:'A',had:'needs'}
          ]
        result = this.needs.of 'A'
        assert.deepEqual result, expected

    describe 'with non-existent object need', ->

      it 'should return error', ->
        expected =
          had: 'needs'
          success: true
          successes: [
            {had:'needs',needsOf:{}, success:true}
          ]
          error:'multiple'
          errors:[
            {error:'unknown need id',type:'invalid request',id:'A',had:'needs'}
          ]
        result = this.needs.of id:'A'
        assert.deepEqual result, expected

  describe 'with single id', ->

    describe 'string', ->

      describe 'and one need we don\'t ask for', ->

        it 'should return error', ->
          need1 = 'A'
          expected =
            had: 'needs'
            success: true
            successes: [
              {had:'needs',needsOf:{}, success:true}
            ]
            error:'multiple'
            errors:[
              {error:'unknown need id',type:'invalid request',id:'B',had:'needs'}
            ]
          result = this.needs.add need1
          result = this.needs.of 'B'
          assert.deepEqual result, expected

      describe 'and one need we do ask for', ->

        it 'should return empty needs for it', ->
          need1 = 'A'
          expected =
            had: 'needs'
            success: true
            needsOf: A:[]
          result = this.needs.add need1
          result = this.needs.of 'A'
          assert.deepEqual result, expected

      describe 'and two needs', ->

        it 'should return empty needs for it', ->
          need1 = 'A'
          need2 = 'B'
          expected =
            had: 'needs'
            success: true
            needsOf: A:[]
          result = this.needs.add need1, need2
          result = this.needs.of 'A'
          assert.deepEqual result, expected

    describe 'object', ->

      describe 'and one need we don\'t ask for', ->

        it 'should return error', ->
          need1 = id:'A'
          expected =
            had: 'needs'
            success: true
            successes: [
              {had:'needs',needsOf:{}, success:true}
            ]
            error:'multiple'
            errors:[
              {error:'unknown need id',type:'invalid request',id:'B',had:'needs'}
            ]
          result = this.needs.add need1
          result = this.needs.of id:'B'
          assert.deepEqual result, expected

      describe 'and one need we do ask for', ->

        it 'should return empty needs for it', ->
          need1 = id:'A'
          expected =
            had: 'needs'
            success: true
            needsOf: A:[]
          result = this.needs.add need1
          result = this.needs.of id:'A'
          assert.deepEqual result, expected

      describe 'and two needs', ->

        it 'should return empty needs for it', ->
          need1 = id:'A'
          need2 = id:'B'
          expected =
            had: 'needs'
            success: true
            needsOf: A:[]
          result = this.needs.add need1, need2
          result = this.needs.of id:'A'
          assert.deepEqual result, expected

      describe 'and one sub-need, ask for wrong one', ->

        it 'should return empty results', ->
          need1 = id:'A', needs:['B']
          need2 = id:'B'
          expected =
            had: 'needs'
            success: true
            needsOf: 'B':[]
          result = this.needs.add need1, need2
          result = this.needs.of id:'B'
          assert.deepEqual result, expected

      describe 'and one sub-need, ask for right one', ->

        it 'should return single need result', ->
          need1 = id:'A', needs:['B']
          need2 = id:'B'
          expected =
            had: 'needs'
            success: true
            needsOf: 'A':[id:'B']
          result = this.needs.add need1, need2
          result = this.needs.of id:'A'
          assert.deepEqual result, expected

      describe 'and a second indirect sub-need', ->

        it 'should return both direct+indirect results', ->
          need1 = id:'A', needs:['B']
          need2 = id:'B', needs:['C']
          need3 = 'C'
          expected =
            had: 'needs'
            success: true
            needsOf: 'A':['C', {id:'B',needs:['C']}]
          result = this.needs.add need1, need2
          result = this.needs.of 'A'
          assert.deepEqual result, expected

  describe 'with multiple ids', ->

    it ''


  describe 'with array of ids (splatted)', ->

    it ''
