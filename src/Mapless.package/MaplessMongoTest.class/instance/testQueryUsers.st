testing
testQueryUsers

	| users |
	
	self do: [ 
	users := OrderedCollection new.

	Character alphabet do: [ :char |
		users add: (MaplessDummyUser new 
					username: char asString;
					person: (MaplessDummyPerson new
								firstName: char asString;
								yourself);
					yourself)].
	
	self assert: ( users allSatisfy: [ :user | user isUnsaved ] ).	
	self assert: ( users allSatisfy: [ :user | user person isUnsaved ] ).	

	self do:[ users do:[ :user | user person save ] ].
	self do:[ users do:[ :user | user save ] ].

	self do:[ 
		self assert: (Character alphabet allSatisfy: [ :char | 
						( MaplessDummyUser findUsername: char asString ) notNil ] ) ]
				]
