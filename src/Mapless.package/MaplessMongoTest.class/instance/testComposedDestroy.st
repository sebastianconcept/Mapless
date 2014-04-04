testing
testComposedDestroy

	| users |
	
	users := OrderedCollection new.

	Character alphabet do: [ :char |
		users add: (MaplessMongoDummyUser new 
					userame: char asString;
					person: (MaplessMongoDummyPerson new
								firstName: char asString;
								yourself);
					yourself)].
	
	self assert: ( users allSatisfy: [ :user | user isUnsaved ] ).	
	self assert: ( users allSatisfy: [ :user | user person isUnsaved ] ).	

	self do:[ users do:[ :user | user person save ] ].
	self do:[ users do:[ :user | user save ] ].

	self assert: ( users allSatisfy: [ :user | user isUnsaved not ] ).	
	self assert: ( users allSatisfy: [ :user | user person isUnsaved not ] ).	

	self do:[ users do:[ :user | user person destroy ] ].
	
	self do:[
		self assert: ( users allSatisfy: [ :user | ( MaplessMongoDummyPerson existsAt: user person oid ) not] ).	
		self assert: ( users allSatisfy: [ :user | MaplessMongoDummyUser existsAt: user oid ] ) ].	

	self do:[ users do:[ :user | user destroy ] ].

	self assert: ( self do: [ users allSatisfy: [ :user | (MaplessMongoDummyUser existsAt: user oid) not ] ] ).	
