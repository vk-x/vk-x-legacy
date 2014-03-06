# [Karma](http://karma-runner.github.io/) config

## Tests tech stack

- [Karma](http://karma-runner.github.io/) - front-end test runner.
It runs our tests code and reports the results.
- [Mocha](http://visionmedia.github.io/mocha/) - test framework.
It provides basic
[BDD](http://en.wikipedia.org/wiki/Behavior-driven_development)-style
testing functions: `describe`, `it`, etc.
- [Chai](http://chaijs.com/) - assertion library.
It provides assertion features like `foo.should.equal "bar"`.

## Write tests
- All tests should be under `test` folder.
- Tests for code in file `source/foo.bar.litcoffee` should be in file
`test/foo.bar.test.litcoffee`. This `.test.` suffix allows to store arbitrary
related files like fixtures inside `test` folder, and to make it easier to
distinguish tests from source in text editors.
- In lieu of a formal styleguide, take care to maintain the existing
coding style. Add unit tests for any new or changed functionality.
Lint and test your code using [gulp](http://gulpjs.com).

## Config
See: http://karma-runner.github.io/0.10/config/configuration-file.html.  
Also see `package.json` file for a list of dependencies.

	module.exports = ( config ) ->
		config.set
			files: [
				"source/*.*"
				"test/*.test.litcoffee" ]

			frameworks: [ "mocha", "chai" ]

			preprocessors:
				"**/*.template.*": [ "lodash" ]
				"**/*.litcoffee": [ "coffee" ]

			lodashPreprocessor:
				data: require "./package.json"

			browsers: [ "PhantomJS" ]
