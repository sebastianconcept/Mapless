tests
testDeleteHook

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeDelete isNil.
	self assert: user afterDelete isNil.
	
	self do: [ user save ]. 

	self do: [ 
		user delete. 
		self assert: user isDeleted ].
	
	self assert: user beforeDelete.
	self assert: user afterDelete.
	