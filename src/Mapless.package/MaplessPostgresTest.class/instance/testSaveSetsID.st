tests
testSaveSetsID

	| guy |
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	
	self do: [ 
		self deny: guy hasId.
	
		guy save.
	
		self assert: guy hasId ]

