testing
testDestroy

	| people |
	
	people := OrderedCollection new.

	Character alphabet do: [ :char |
		people add: (MaplessRedisDummyPerson new
						firstName: char asString;
						yourself)].
	
	self assert: ( people allSatisfy: [ :guy | guy isUnsaved ] ).	

	self do:[ people do:[ :guy | guy save ] ].

	self assert: ( people allSatisfy: [ :guy | guy isUnsaved not ] ).	
	self assert: ( people allSatisfy: [ :guy | guy isDeleted not ] ).	
	
	self do:[ people do:[ :guy | guy destroy ] ].
	self assert: ( self do:[ people allSatisfy: [ :guy | ( MaplessRedisDummyPerson existsAt: guy oid ) not ] ]).
