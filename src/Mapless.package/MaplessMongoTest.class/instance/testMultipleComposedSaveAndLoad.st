testing
testMultipleComposedSaveAndLoad

	| user guy tags loaded |
	
	self do: [ 
	user := MaplessDummyUser new
				username: 'johnq';
				yourself.
	
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	tags := OrderedCollection new.
	tags 
		add: (MaplessDummyTag new label: 'cool'; yourself);	
		add: (MaplessDummyTag new label: 'stuff'; yourself);	
		yourself.
		
	user 
		person: guy;
		tags: tags;
		yourself.
		
	self do:[ tags do:[ :tag | tag save] ].
	self do:[ guy save ].
	self shouldnt: [ self do:[ user save ] ] raise: MaplessUnsavedSubmodel.
	
	self deny: user isUnsaved.	
	self deny: guy isUnsaved.	
	self assert: (tags allSatisfy: [:e| e isUnsaved not]).

	self do:[ loaded := MaplessDummyUser findId: user id.
		self assert: loaded notNil.
		self deny: loaded isUnsaved.
		self assert: loaded username = 'johnq'.
		self assert: loaded tags isCollection.
		self assert: loaded tags notEmpty.
		self assert: loaded tags isCollection.
		loaded tags do:[:tag|
			self assert: (tags anySatisfy:[:t| t id = tag id])].
		] ]
