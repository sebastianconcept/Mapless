tests
testComposedDestroy

	| users |
	
	self do: [ 
	users := OrderedCollection new.

	Character alphabet do: [ :char |
		users add: (DummyUser new 
					userame: char asString;
					person: (DummyPerson new
								firstName: char asString;
								yourself);
					yourself)].
	
	self assert: ( users allSatisfy: [ :user | user isUnsaved ] ).	
	self assert: ( users allSatisfy: [ :user | user person isUnsaved ] ).	

	users do:[ :user | user person save ].
	users do:[ :user | user save ].

	self assert: ( users allSatisfy: [ :user | user isUnsaved not ] ).	
	self assert: ( users allSatisfy: [ :user | user person isUnsaved not ] ).	

	users do:[ :user | user person destroy ] .
	
	self assert: ( users allSatisfy: [ :user | ( DummyPerson existsId: user person oid ) not] ).	
	self assert: ( users allSatisfy: [ :user | DummyUser existsId: user oid ] ) .	

	users do:[ :user | user destroy ] .

	self assert: ( users allSatisfy: [ :user | (DummyUser existsId: user oid) not ]  )
	 ]
