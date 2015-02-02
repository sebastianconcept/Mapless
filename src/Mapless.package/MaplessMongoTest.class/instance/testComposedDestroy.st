testing
testComposedDestroy

	| users |
	
	self do: [ 
	users := OrderedCollection new.

	Character alphabet do: [ :char |
		users add: (MaplessDummyUser new 
					userame: char asString;
					person: (MaplessDummyPerson new
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
		self assert: ( users allSatisfy: [ :user | ( MaplessDummyPerson existsId: user person id ) not] ).	
		self assert: ( users allSatisfy: [ :user | MaplessDummyUser existsId: user id ] ) ].	

	self do:[ users do:[ :user | user destroy ] ].

	self assert: ( self do: [ users allSatisfy: [ :user | (MaplessDummyUser existsId: user id) not ] ] ).	
	
	 ]
