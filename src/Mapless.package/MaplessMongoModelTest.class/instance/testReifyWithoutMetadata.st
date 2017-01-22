tests
testReifyWithoutMetadata

	| user serializedWith serializedWithout |

	user := DummyPerson new
			firstName: 'john';
			yourself.

	serializedWith := '{"id": "abc123", "modelClass": "DummyPerson","createdOn": "2017-01-22T13:49:37.564031+00:00","firstName": "john"}'.
	
	serializedWithout :=  '{"id": "abc123", "createdOn": "2017-01-22T13:49:37.564031+00:00","firstName": "john"}'.
	
	self do:[ 
		self assert: (DummyPerson fromJSONString: serializedWith) class == DummyPerson.
		self assert: (DummyPerson fromJSONString: serializedWithout) class == DummyPerson.

		self assert: (DummyUser fromJSONString: serializedWithout) class == DummyUser.
	]