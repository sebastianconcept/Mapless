tests
testUnrefDestroy2

	| friends guy stuff loaded reified reloaded | 
	
	self do: [ 
	friends := OrderedCollection new
				add: (DummyPerson new
						firstName: 'Frodo';
						yourself);
				add: (DummyPerson new
						firstName: 'Gandalf';
						yourself);
				add: (DummyPerson new
						firstName: 'Boromir';
						yourself);
				yourself.
				
	stuff := #('Ice cream' 'waffles' 'french fries').
	
	guy := DummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
	
	friends do: [:e | e save].
	guy save.
	self deny: guy isUnsaved.
	
	self do:[ loaded := DummyPerson findId: guy oid].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	reified := loaded unreferenced.

	self assert: reified data friends class = OrderedCollection.
	reified destroy.

	"By design, the destruction should be to the individual aggregate (and not its submodels).
	It's programmers' responsability to decide when to destroy a sub aggregate"	
	self assert: ( self do: [ reloaded := DummyPerson existsId: loaded oid]) not.	
	self do:[self assert: ((friends collect: [:e| e oid]) allSatisfy: [:guyOid|
					(DummyPerson existsId: guyOid)])]
			]

				
	