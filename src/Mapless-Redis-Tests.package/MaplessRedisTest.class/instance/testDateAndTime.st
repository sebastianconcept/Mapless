tests
testDateAndTime


	| when guy loaded |
	
	self do: [ 
	when := DateAndTime now.
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			createdOn: when;
			yourself.
	
	self assert: guy isUnsaved.	
	guy save .
	self deny: guy isUnsaved.

	loaded := DummyPerson findId: guy id .

	self assert: loaded createdOn asDate asString = when asDate asString.
	self assert: loaded createdOn asTime hour = when asTime hour.
	self assert: loaded createdOn asTime minutes = when asTime minutes.
	self assert: loaded createdOn asTime seconds = when asTime seconds.
	]

