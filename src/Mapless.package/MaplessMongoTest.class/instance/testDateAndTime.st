testing
testDateAndTime

	| when guy loaded |
	
	when := DateAndTime now.
	guy := MaplessMongoDummyPerson new
			firstName: 'john';
			lastName: 'q';
			createdOn: when;
			yourself.
	
	self assert: guy isUnsaved.	
	self do:[ guy save ].
	self deny: guy isUnsaved.

	self do:[ loaded := MaplessMongoDummyPerson findAt: guy id ].

	self assert: loaded createdOn asDate asString = when asDate asString.
	self assert: loaded createdOn asSeconds = when asSeconds.
