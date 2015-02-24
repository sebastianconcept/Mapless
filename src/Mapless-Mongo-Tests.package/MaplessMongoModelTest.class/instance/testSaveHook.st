tests
testSaveHook

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeSave isNil.
	self assert: user afterSave isNil.
	
	self do: [ user save ].
	
	self assert: user beforeSave.
	self assert: user afterSave.
	