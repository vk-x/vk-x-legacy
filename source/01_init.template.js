window.<%= name %> = {
	name: "<%= name %>",
	version: {
		full: "<%= version %>",
		major: <%= version.split( "." )[ 0 ] %>,
		minor: <%= version.split( "." )[ 1 ] %>,
		patch: <%= version.split( "." )[ 2 ] %>
	},
	homepage: "<%= homepage %>"
};

var app = window.<%= name %>;
