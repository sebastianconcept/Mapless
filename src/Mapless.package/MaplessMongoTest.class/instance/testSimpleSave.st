testing
testSimpleSave

	| guy |
	
	guy := MaplessMongoDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	
	self assert: guy isUnsaved.	
	self do:[ guy save ].
	self deny: guy isUnsaved.
