tests
testComposedAccess
	"Test proxies and its on-demand-load and DNU mechanism"

	| user guy |
	
	user := DummyUser new
				userame: 'johnq';
				yourself.
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.

	self do:[ 
		guy save.
		user save ].
	
	self do:[
		self assert: ( DummyUser findId: user id ) completeName = 'john q'.
		self assert: ( DummyUser findId: user id ) person class = MaplessReference.
		self assert: ( DummyUser findId: user id ) person model class = DummyPerson.
		self assert: ( DummyUser findId: user id ) person firstName = 'john'.
		self assert: ( DummyUser findId: user id ) person lastName = 'q' ]
