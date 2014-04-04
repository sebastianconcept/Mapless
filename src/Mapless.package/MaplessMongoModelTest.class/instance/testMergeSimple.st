tests
testMergeSimple

	| user newerUser|

	user := MaplessMongoDummyUser new
			username: 'johnq';
			yourself.

	newerUser := MaplessMongoDummyUser new
			email: 'johnq@email';
			yourself.

	self assert: user email isNil.
	self assert: newerUser username isNil.

	user merge: newerUser.

	self assert: user email notNil.
	self assert: user email = newerUser email.
	self assert: newerUser username isNil.
	