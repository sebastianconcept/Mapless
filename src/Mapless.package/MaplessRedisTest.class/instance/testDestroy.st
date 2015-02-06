testing
testDestroy

	| people |
	
	self do: [ 
	people := OrderedCollection new.

	Character alphabet do: [ :char |
		people add: (MaplessDummyPerson new
						firstName: char asString;
						yourself)].
	
	self assert: ( people allSatisfy: [ :guy | guy isUnsaved ] ).	

	people do:[ :guy | guy save ] .

	self assert: ( people allSatisfy: [ :guy | guy isUnsaved not ] ).	
	self assert: ( people allSatisfy: [ :guy | guy isDeleted not ] ).	
	
	people do:[ :guy | guy destroy ] .
	self assert: ( people allSatisfy: [ :guy | ( MaplessDummyPerson existsAt: guy oid ) not ] )  ]
