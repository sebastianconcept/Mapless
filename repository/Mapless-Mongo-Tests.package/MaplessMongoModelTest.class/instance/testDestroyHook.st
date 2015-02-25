tests
testDestroyHook

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeDestroy isNil.
	self assert: user afterDestroy isNil.
	
	self do: [ user save ]. 
	self do: [ user destroy ].
	
	self assert: user beforeDestroy.
	self assert: user afterDestroy.
	