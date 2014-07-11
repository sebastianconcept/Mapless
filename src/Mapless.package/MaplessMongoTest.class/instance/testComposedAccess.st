testing
testComposedAccess
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	
	user := MaplessMongoDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessMongoDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.

	self do:[ 
		guy save.
		user save ].
	
	self do:[
		self assert: ( MaplessMongoDummyUser findId: user oid ) completeName = 'john q'.
		self assert: ( MaplessMongoDummyUser findId: user oid ) person class = MaplessReference.
		self assert: ( MaplessMongoDummyUser findId: user oid ) person model class = MaplessMongoDummyPerson.
		self assert: ( MaplessMongoDummyUser findId: user oid ) person firstName = 'john'.
		self assert: ( MaplessMongoDummyUser findId: user oid ) person lastName = 'q' ]
