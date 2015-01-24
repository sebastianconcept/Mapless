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
	self do: [ guy save ].
	self deny: guy isUnsaved.

	self do: [ loaded := MaplessMongoDummyPerson findId: guy id ].

	self assert: loaded createdOn asDate asString = when asDate asString.
	self assert: loaded createdOn asTime hour = when asTime hour.
	self assert: loaded createdOn asTime minutes = when asTime minutes.
	self assert: loaded createdOn asTime seconds = when asTime seconds.
	
