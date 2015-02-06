tests
testSaveHook

	| user |

	user := MaplessDummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeSaved isNil.
	self assert: user afterSaved isNil.
	
	user save.
	
	self assert: user beforeSaved.
	self assert: user afterSaved.
	