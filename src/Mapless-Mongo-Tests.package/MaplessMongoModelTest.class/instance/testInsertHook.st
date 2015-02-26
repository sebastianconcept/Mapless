tests
testInsertHook

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeInsert isNil.
	self assert: user afterInsert isNil.
	
	self do: [ user insert ].
	
	self assert: user beforeInsert.
	self assert: user afterInsert.
	