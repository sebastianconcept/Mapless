tests
testSimpleSave

	| guy |
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	
	self do: [ 
		self assert: guy isUnsaved.
	
		guy save.
	
		self deny: guy isUnsaved ]

