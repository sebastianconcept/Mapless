testing
testComposedDestroy

	| users |
	
	users := OrderedCollection new.

	Character alphabet do: [ :char |
		users add: (MaplessRedisDummyUser new 
					userame: char asString;
					person: (MaplessRedisDummyPerson new
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
		self assert: ( users allSatisfy: [ :user | ( MaplessRedisDummyPerson existsAt: user person oid ) not] ).	
		self assert: ( users allSatisfy: [ :user | MaplessRedisDummyUser existsAt: user oid ] ) ].	

	self do:[ users do:[ :user | user destroy ] ].

	self assert: ( self do: [ users allSatisfy: [ :user | (MaplessRedisDummyUser existsAt: user oid) not ] ] ).	
