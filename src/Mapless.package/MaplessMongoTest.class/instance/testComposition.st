testing
testComposition

	| user guy |
	
	user := MaplessMongoDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessMongoDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	self assert: user isUnsaved.
	self assert: guy isUnsaved.	
	self assert: ((user data at: 'person') class = MaplessMongoDummyPerson ).
	self assert: ((user data at: 'person') modelClass = #MaplessMongoDummyPerson).
	self assert: user oid isNil.
	self assert: (user data at: 'person') oid isNil.
	self assert: (user completeName = 'john q').
	
	
	