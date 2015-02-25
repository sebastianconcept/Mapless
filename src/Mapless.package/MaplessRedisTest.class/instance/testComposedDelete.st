tests
testComposedDelete

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

	users do:[ :user | user person save ] .
	users do:[ :user | user save ].

	self assert: ( users allSatisfy: [ :user | user isUnsaved not ] ).	
	self assert: ( users allSatisfy: [ :user | user person isUnsaved not ] ).	
	self assert: ( users allSatisfy: [ :user | user isDeleted not ] ).	
	self assert: ( users allSatisfy: [ :user | user person isDeleted not ] ).	

	users do:[ :user | user person delete ].
	
	self assert: ( users allSatisfy: [ :user | user person isDeleted ] ).	
	self assert: ( users allSatisfy: [ :user | user isDeleted not ] ).	

	users do:[ :user | user delete ].

	self assert: ( users allSatisfy: [ :user | user person isDeleted ] ).	
	self assert: ( users allSatisfy: [ :user | user isDeleted ] )
	]
