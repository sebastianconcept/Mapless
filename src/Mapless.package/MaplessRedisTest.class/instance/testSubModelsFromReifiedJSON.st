testing
testSubModelsFromReifiedJSON

	| user guy json reified |
	
	user := MaplessRedisDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessRedisDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	json := user unreferenced asJSONString.

	reified := MaplessMongoDummyUser fromJSON: json.

	self assert: guy isUnsaved.	
	self assert: reified person class = MaplessMongoDummyPerson.
	self assert: reified completeName = 'john q'.
