testing
testDestroy

	| people |
	
	people := OrderedCollection new.

	Character alphabet do: [ :char |
		people add: (MaplessMongoDummyPerson new
						firstName: char asString;
						yourself)].
	
	self assert: ( people allSatisfy: [ :guy | guy isUnsaved ] ).	

	self do:[ people do:[ :guy | guy save ] ].

	self assert: ( people allSatisfy: [ :guy | guy isUnsaved not ] ).	
	self assert: ( people allSatisfy: [ :guy | guy isDeleted not ] ).	
	
	self do:[ people do:[ :guy | guy destroy ] ].
	self assert: ( self do:[ people allSatisfy: [ :guy | ( MaplessMongoDummyPerson existsAt: guy oid ) not ] ]).
