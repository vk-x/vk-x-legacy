window.<%= name %> = {
	name: "<%= name %>",
	version: "<%= version %>",
	homepage: "<%= homepage %>"
};

var app = window.<%= name %>;

app.version.major = <%= version.split( "." )[ 0 ] %>;
app.version.minor = <%= version.split( "." )[ 1 ] %>;
app.version.patch = <%= version.split( "." )[ 2 ] %>;
