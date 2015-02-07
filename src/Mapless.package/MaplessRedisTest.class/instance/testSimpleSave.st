tests
testSimpleSave

	| guy |
	
	self do: [ 
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	
	self assert: guy isUnsaved.	
	guy save .
	self deny: guy isUnsaved.
	]