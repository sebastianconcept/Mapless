testing
testComposedAccess
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	
	user := MaplessRedisDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessRedisDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.

	self do:[ 
		guy save.
		user save ].
	
	self do:[
		self assert: ( MaplessRedisDummyUser findId: user oid ) completeName = 'john q'.
		self assert: ( MaplessRedisDummyUser findId: user oid ) person class = MaplessReference.
		self assert: ( MaplessRedisDummyUser findId: user oid ) person model class = MaplessRedisDummyPerson.
		self assert: ( MaplessRedisDummyUser findId: user oid ) person firstName = 'john'.
		self assert: ( MaplessRedisDummyUser findId: user oid ) person lastName = 'q' ]
