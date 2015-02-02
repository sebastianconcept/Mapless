testing
testSubModelsFromReifiedJSON

	| user guy jsonString reified |
	
	self do: [ 
	user := MaplessDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	jsonString := user unreferenced asJSONString.

	reified := MaplessDummyUser fromJSONString: jsonString.

	self assert: guy isUnsaved.	
	self assert: reified person class = MaplessDummyPerson.
	self assert: reified completeName = 'john q'.
	]
