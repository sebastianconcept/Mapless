testing
testSubModelsFromReifiedJSON

	| user guy jsonString reified |
	
	user := MaplessMongoDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessMongoDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	jsonString := user unreferenced asJSONString.

	reified := MaplessMongoDummyUser fromJSONString: jsonString.

	self assert: guy isUnsaved.	
	self assert: reified person class = MaplessMongoDummyPerson.
	self assert: reified completeName = 'john q'.
