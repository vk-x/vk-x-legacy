describe( "app", function() {
	it( "should have correct metadata", function() {
		app.name.should.equal( "<%= name %>" );
		app.version.should.deep.equal({
			full: "<%= version %>",
			major: <%= version.split( "." )[ 0 ] %>,
			minor: <%= version.split( "." )[ 1 ] %>,
			patch: <%= version.split( "." )[ 2 ] %>
		});
		app.homepage.should.equal( "<%= homepage %>" );
	});

	it( "should have an alias window.<%= name %>", function() {
		window.<%= name %>.should.equal( app );
	});
});
