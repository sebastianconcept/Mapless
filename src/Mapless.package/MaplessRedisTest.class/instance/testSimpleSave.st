testing
testSimpleSave

	| guy |
	
	self do: [ 
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	
	self assert: guy isUnsaved.	
	guy save .
	self deny: guy isUnsaved.
	]