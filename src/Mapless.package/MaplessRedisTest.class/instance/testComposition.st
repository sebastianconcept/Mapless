testing
testComposition

	| user guy |
	
	user := MaplessRedisDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessRedisDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	self assert: guy isUnsaved.	
	self assert: ((user data at: 'person') class = MaplessReference).
	self assert: ((user data at: 'person') modelClass = #MaplessRedisDummyPerson).
	self assert: ((user data at: 'person') oid = guy oid).
	self assert: (user completeName = 'john q').
	
	
	