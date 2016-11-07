0.5.1 - 2016/11/06

1. update `ordered()` to return empty success when there are no needs to operate on
2. update `ordered()` to only `_search()` when some `ids` are found to search with
3. update `ordered()` to ensure all needs are returned in result array, otherwise, return an error
4. update both `_search()` and `_searchStep()` to return immediately when encountering an error
5. fixed the problem of having cyclical needs not included in result but an object without needs is
6. added tests for a few more variations of cyclical problems

0.5.0 - 2016/11/06

1. added this CHANGES file
2. updated all dependencies
3. DRY'd npm scripts and renamed 'compile' to 'build'
4. eliminated middleman `index.js` and pointed right at `lib/`
