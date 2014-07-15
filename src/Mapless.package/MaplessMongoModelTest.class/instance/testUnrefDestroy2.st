tests
testUnrefDestroy2

	| friends guy stuff loaded reified reloaded | 
	
	friends := OrderedCollection new
				add: (MaplessMongoDummyPerson new
						firstName: 'Frodo';
						yourself);
				add: (MaplessMongoDummyPerson new
						firstName: 'Gandalf';
						yourself);
				add: (MaplessMongoDummyPerson new
						firstName: 'Boromir';
						yourself);
				yourself.
				
	stuff := #('Ice cream' 'waffles' 'french fries').
	
	guy := MaplessMongoDummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
	
	self do: [friends do: [:e | e save]].
	self do:[guy save].
	self deny: guy isUnsaved.
	
	self do:[ loaded := MaplessMongoDummyPerson findAt: guy oid].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data friends class = OrderedCollection.
	self do: [ reified destroy].

	"By design, the destruction should be to the individual aggregate (and not its submodels).
	It's programmers' responsability to decide when to destroy a sub aggregate"	
	self assert: ( self do: [ reloaded := MaplessMongoDummyPerson existsAt: loaded oid]) not.	
	self do:[self assert: ((friends collect: [:e| e oid]) allSatisfy: [:guyOid|
					(MaplessMongoDummyPerson existsAt: guyOid)])]

				
	