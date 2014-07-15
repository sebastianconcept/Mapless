testing
testDateAndTime

	| when guy loaded |
	
	when := DateAndTime now.
	guy := MaplessRedisDummyPerson new
			firstName: 'john';
			lastName: 'q';
			createdOn: when;
			yourself.
	
	self assert: guy isUnsaved.	
	self do:[ guy save ].
	self deny: guy isUnsaved.

	self do:[ loaded := MaplessRedisDummyPerson findAt: guy id ].

	self assert: loaded createdOn asDate = when asDate.
	self assert: loaded createdOn asTime = when asTime .
	self assert: loaded createdOn = when.
