tests
testSubModelsFromReifiedJSON

	| user guy jsonString reified |
	
	self do: [ 
	user := DummyUser new
				userame: 'johnq';
				yourself.
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	jsonString := user unreferenced asJSONString.

	reified := DummyUser fromJSONString: jsonString.

	self assert: guy isUnsaved.	
	self assert: reified person class = DummyPerson.
	self assert: reified completeName = 'john q'.
	]
