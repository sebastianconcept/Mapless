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
	guy save.
	self deny: guy isUnsaved.

	loaded := DummyPerson findId: guy id.
	
	self assert: loaded createdOn truncated asUTC = when truncated asUTC.
	]
