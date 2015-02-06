testing
testComposedSaveAndLoad

	| user guy loaded |
	
	self do: [ 
	user := MaplessDummyUser new
				username: 'johnq';
				yourself.
	
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	"Whithout saving a submodel"
	self assert: user isUnsaved.	
	self assert: guy isUnsaved.	
	self should: [ user save ] raise: MaplessUnsavedSubmodel.

	"After saving that submodel"
	guy save .
	self shouldnt: [ user save ] raise: MaplessUnsavedSubmodel.
	
	self deny: user isUnsaved.	
	self deny: guy isUnsaved.	

	loaded := MaplessDummyUser findAt: user oid.
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	loaded keysAndValuesDo:[:k :v|
		self assert: (user includesKey: k).
		self assert: (user at: k) = v].
	self assert: loaded username = 'johnq'.
	self assert: loaded person firstName = 'john'.
	self assert: loaded person lastName = 'q'.
	self assert: loaded person modelClass = MaplessDummyPerson asString.
	self assert: loaded person model class = MaplessDummyPerson.
		]
