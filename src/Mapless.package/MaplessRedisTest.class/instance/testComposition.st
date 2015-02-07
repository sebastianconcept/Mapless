tests
testComposition

	| user guy |
	
	self do: [ 
	user := DummyUser new
				userame: 'johnq';
				yourself.
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	self assert: user isUnsaved.
	self assert: guy isUnsaved.	
	self assert: ((user data at: 'person') class = DummyPerson ).
	self assert: ((user data at: 'person') modelClass = #DummyPerson).
	self assert: user id isNil.
	self assert: (user data at: 'person') id isNil.
	self assert: (user completeName = 'john q')]
	
	
	