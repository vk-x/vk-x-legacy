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
- [Sinon.JS](http://sinonjs.org/) - spy/stub/mock library.
See [its docs](http://sinonjs.org/docs) for more.

## Write tests

- All unit tests should be under [`test/unit`](unit/) folder.
- Tests for `source/foo.litcoffee` should be in file
`test/unit/foo.litcoffee`. Directory structure should be mirrored for
convenience.
- Add new unit test files to
[`test/unit/index.litcoffee`](unit/index.litcoffee).
- Add unit tests for any new or changed functionality.

## Config

See: http://karma-runner.github.io/0.12/config/configuration-file.html.  
Also see `package.json` file for a list of dependencies.

	module.exports = ( config ) ->
		config.set

			logLevel: config.LOG_WARN

			files: [ "./unit/index.litcoffee" ]

			frameworks: [ "mocha", "sinon-chai", "browserify" ]

			preprocessors:
				"**/*.template.*": [ "lodash" ]
				"**/*.litcoffee": [ "coffee" ]
				"./unit/**/*.*": [ "browserify" ]

			lodashPreprocessor: data: require "../package.json"

			browserify: require "../build/browserify-config"

			browsers: [ "PhantomJS" ]

			singleRun: yes
