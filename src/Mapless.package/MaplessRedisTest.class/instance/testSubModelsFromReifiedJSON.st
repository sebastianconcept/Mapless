testing
testSubModelsFromReifiedJSON

	| user guy json reified |
	
	
	self do: [ 
	user := MaplessDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	json := user unreferenced asJSONString.

	reified := MaplessDummyUser fromJSONString: json.

	self assert: guy isUnsaved.	
	self assert: reified person class = MaplessDummyPerson.
	self assert: reified completeName = 'john q'.
	]
