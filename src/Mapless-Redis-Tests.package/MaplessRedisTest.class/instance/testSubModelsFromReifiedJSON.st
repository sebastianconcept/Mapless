tests
testSubModelsFromReifiedJSON

	| user guy json reified |
	
	
	self do: [ 
	user := DummyUser new
				userame: 'johnq';
				yourself.
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	json := user unreferenced asJSONString.

	reified := DummyUser fromJSONString: json.

	self assert: guy isUnsaved.	
	self assert: reified person class = DummyPerson.
	self assert: reified completeName = 'john q'.
	]
