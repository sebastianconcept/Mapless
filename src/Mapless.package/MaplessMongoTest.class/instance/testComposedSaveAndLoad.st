tests
testComposedSaveAndLoad

	| user guy loaded |
	
	self do: [ 
	user := DummyUser new
				username: 'johnq';
				yourself.
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	"Whithout saving a submodel"
	self assert: user isUnsaved.	
	self assert: guy isUnsaved.	
	self should: [ self do:[ user save ] ] raise: MaplessUnsavedSubmodel.

	"After saving that submodel"
	self do:[ guy save ].
	self shouldnt: [ self do:[ user save ] ] raise: MaplessUnsavedSubmodel.
	
	self deny: user isUnsaved.	
	self deny: guy isUnsaved.	

	self do:[ loaded := DummyUser findId: user id.
		self assert: loaded notNil.
		self deny: loaded isUnsaved.
		self assert: loaded createdOn notNil.
		self assert: loaded modifiedOn notNil.
		loaded createdOn: nil; modifiedOn: nil.
		user createdOn: nil; modifiedOn: nil.
		loaded data keysAndValuesDo: [ :k :v |
			self assert: v = ( user data at: k ) ].
		self assert: loaded username = 'johnq'.
		self assert: loaded person firstName = 'john'.
		self assert: loaded person lastName = 'q'.
		self assert: loaded person modelClass = DummyPerson asString.
		self assert: loaded person model class = DummyPerson.
		]
	 ]