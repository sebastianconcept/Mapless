tests
testSimpleSaveAndUpdate

	| guy loaded reloaded |
	
	self do: [ 
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	
	self assert: guy isUnsaved.	
	self do:[ guy save ].
	self deny: guy isUnsaved.

	self do: [ loaded := DummyPerson findId: guy id ].
	self assert: loaded firstName = 'john'.
	self deny: loaded remember = 'this words'.
	loaded remember: 'this words'.
	self do: [ loaded save ].
	
	self do: [ reloaded :=  DummyPerson findId: guy id ].
	self assert: reloaded remember = 'this words'
	]
	
	