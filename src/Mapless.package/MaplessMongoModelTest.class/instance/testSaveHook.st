tests
testSaveHook

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeSaved isNil.
	self assert: user afterSaved isNil.
	
	self do: [ user save ].
	
	self assert: user beforeSaved.
	self assert: user afterSaved.
	