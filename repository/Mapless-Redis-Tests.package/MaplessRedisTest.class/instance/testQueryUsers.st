tests
testQueryUsers

	| users |
	
	users := OrderedCollection new.

	Character alphabet do: [ :char |
		users add: (DummyUser new 
					username: char asString;
					person: (DummyPerson new
								firstName: char asString;
								yourself);
					yourself)].
	
	self do: [ 
		self assert: ( users allSatisfy: [ :user | user isUnsaved ] ).	
		self assert: ( users allSatisfy: [ :user | user person isUnsaved ] ) ].	

	self do:[ users do:[ :user | user person save ] ].
	self do:[ users do:[ :user | user save ] ].

	self do:[ 
		self assert: (Character alphabet allSatisfy: [ :char | 
						( DummyUser findUsername: char asString ) notNil ] ) ]
			
