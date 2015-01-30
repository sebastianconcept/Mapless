testing
testMultipleComposedMixedSaveAndLoad

	| guy things loaded |
	
	self do: [ 
	guy := MaplessDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.

	guy things: OrderedCollection new.
	guy things 
		add: (MaplessDummyTag new label: 'cool'; yourself);	
		add: (MaplessDummyTag new label: 'stuff'; yourself);	
		add: (MaplessDummyUser new info: 'also this'; yourself);	
		yourself.

	things := guy things.
		
	self do:[ guy things do:[ :each | each save] ].
	self shouldnt: [ self do:[ guy save ] ] raise: MaplessUnsavedSubmodel.
	
	self deny: guy isUnsaved.	
	self assert: (things allSatisfy: [:e| e isUnsaved not]).

	self do:[ loaded := MaplessDummyPerson findAt: guy oid.
		self assert: loaded notNil.
		self deny: loaded isUnsaved.
		self assert: loaded firstName = 'john'.
		self assert: loaded things isCollection.
		self assert: loaded things notEmpty.
		
		loaded things do:[:each|
			self assert: (things anySatisfy: [ :t | t id = each id ] ) ].
		loaded unreferenced.
		self assert: loaded things first class = MaplessDummyTag.
		self assert: loaded things second class = MaplessDummyTag.
		self assert: loaded things third class = MaplessDummyUser.
		]
	 ]
