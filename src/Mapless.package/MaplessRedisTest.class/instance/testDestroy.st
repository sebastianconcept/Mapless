tests
testDestroy

	| people |
	
	self do: [ 
	people := OrderedCollection new.

	Character alphabet do: [ :char |
		people add: (DummyPerson new
						firstName: char asString;
						yourself)].
	
	self assert: ( people allSatisfy: [ :guy | guy isUnsaved ] ).	

	people do:[ :guy | guy save ] .

	self assert: ( people allSatisfy: [ :guy | guy isUnsaved not ] ).	
	self assert: ( people allSatisfy: [ :guy | guy isDeleted not ] ).	
	
	people do:[ :guy | guy destroy ] .
	self assert: ( people allSatisfy: [ :guy | ( DummyPerson existsId: guy oid ) not ] )  ]
