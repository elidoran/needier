assert = require 'assert'
needier = require '../lib'

describe 'test update', ->

  beforeEach 'new Needs', -> this.needs = needier()

  describe 'type combine', ->

    describe 'with no sub-needs', ->

      describe 'add one new subneed', ->

        it 'should be the only subneed', ->
          need = 'A'
          this.needs.add need

          expected =
            success: true
            had: 'needs'
            added: B:'B'

          result = this.needs.update id:'A', needs:['B'], type:'combine'
          assert.deepEqual result, expected

          expected =
            success:true
            had:'needs'
            needsOf: A:['B']
          result = this.needs.of 'A'
          assert.deepEqual result, expected

      describe 'add two new subneeds', ->

        it 'should be the only subneed', ->
          need = 'A'
          this.needs.add need

          expected =
            success: true
            had: 'needs'
            added: B:'B',C:'C'
          result = this.needs.update id:'A', needs:['B','C'], type:'combine'
          assert.deepEqual result, expected

          expected =
            success:true
            had:'needs'
            needsOf: A:['B','C']
          result = this.needs.of 'A'
          assert.deepEqual result, expected

    describe 'with one sub-need', ->

      describe 'add one new subneed', ->

        it 'should combine the subneeds', ->
          need = id:'C', needs:['A']
          this.needs.add need

          expected =
            success: true
            had: 'needs'
            added: B:'B'
          result = this.needs.update id:'C', needs:['B'], type:'combine'
          assert.deepEqual result, expected

          expected =
            success:true
            had:'needs'
            needsOf: C:['A','B']
          result = this.needs.of 'C'
          assert.deepEqual result, expected

      describe 'add two new subneeds', ->

        it 'should combine the subneeds', ->
          need = id:'D', needs:['A']
          this.needs.add need

          expected =
            success: true
            had: 'needs'
            added: B:'B', C:'C'
          result = this.needs.update id:'D', needs:['B','C'], type:'combine'
          assert.deepEqual result, expected

          expected =
            success:true
            had:'needs'
            needsOf: D:['A','B','C']
          result = this.needs.of 'D'
          assert.deepEqual result, expected
