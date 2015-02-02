testing
testComposedAccess
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	
	user := MaplessDummyUser new
				userame: 'johnq';
				yourself.
	
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.

	self do:[ 
		guy save.
		user save ].
	
	self do:[
		self assert: ( MaplessDummyUser findId: user oid ) completeName = 'john q'.
		self assert: ( MaplessDummyUser findId: user oid ) person class = MaplessReference.
		self assert: ( MaplessDummyUser findId: user oid ) person model class = MaplessDummyPerson.
		self assert: ( MaplessDummyUser findId: user oid ) person firstName = 'john'.
		self assert: ( MaplessDummyUser findId: user oid ) person lastName = 'q' ]
