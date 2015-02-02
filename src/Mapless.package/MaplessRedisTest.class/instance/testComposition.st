testing
testComposition

	| user guy |
	
	self do: [ 
	user := MaplessDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	self assert: user isUnsaved.
	self assert: guy isUnsaved.	
	self assert: ((user data at: 'person') class = MaplessDummyPerson ).
	self assert: ((user data at: 'person') modelClass = #MaplessDummyPerson).
	self assert: user id isNil.
	self assert: (user data at: 'person') id isNil.
	self assert: (user completeName = 'john q')]
	
	
	