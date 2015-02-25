tests
testUpdatetHook

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeUpdate isNil.
	self assert: user afterUpdate isNil.
	
	self do: [ 
			user save.
			user save. ]. 
	
	self assert: user beforeUpdate.
	self assert: user afterUpdate.
	