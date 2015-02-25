tests
testMergeComposed

	| user guy newerUser newerGuy |

	self do: [ 
	user := DummyUser new
			username: 'johnq';
			yourself.

	guy := DummyPerson new
			firstName: 'John';
			yourself.

	user person: guy.
	
	newerUser := DummyUser new
			email: 'johnq@email';
			yourself.

	newerGuy := DummyPerson new
			firstName: 'JohM';
			lastName: 'Q';
			yourself.
	newerUser person: newerGuy.

	user merge: newerUser.

	self assert: newerUser username isNil.
	self deny: user person firstName = 'JohM'.

	self assert: user email notNil.
	self assert: user email = newerUser email.
	self assert: user person firstName = 'John'.	
	self assert: user person lastName = 'Q']	