tests
testComposedSave

	| user guy |
	
	self do: [ 
	user := DummyUser new
				userame: 'johnq';
				yourself.
	
	guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	user person: guy.
		
	"Whithout saving a submodel"
	self assert: user isUnsaved.	
	self assert: guy isUnsaved.	
	self should: [ user save ] raise: MaplessUnsavedSubmodel.

	"After saving that submodel"
	guy save.
	self shouldnt: [user save ] raise: MaplessUnsavedSubmodel.
	
	self deny: user isUnsaved.	
	self deny: guy isUnsaved
	]

