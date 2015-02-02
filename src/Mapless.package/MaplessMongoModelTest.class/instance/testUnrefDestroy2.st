tests
testUnrefDestroy2

	| friends guy stuff loaded reified reloaded | 
	
	self do: [ 
	friends := OrderedCollection new
				add: (MaplessDummyPerson new
						firstName: 'Frodo';
						yourself);
				add: (MaplessDummyPerson new
						firstName: 'Gandalf';
						yourself);
				add: (MaplessDummyPerson new
						firstName: 'Boromir';
						yourself);
				yourself.
				
	stuff := #('Ice cream' 'waffles' 'french fries').
	
	guy := MaplessDummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
	
	self do: [friends do: [:e | e save]].
	self do:[guy save].
	self deny: guy isUnsaved.
	
	self do:[ loaded := MaplessDummyPerson findId: guy id].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data friends class = OrderedCollection.
	self do: [ reified destroy].

	"By design, the destruction should be to the individual aggregate (and not its submodels).
	It's programmers' responsability to decide when to destroy a sub aggregate"	
	self assert: ( self do: [ reloaded := MaplessDummyPerson existsId: loaded id]) not.	
	self do:[self assert: ((friends collect: [:e| e id]) allSatisfy: [:guyId|
					(MaplessDummyPerson existsId: guyId)])]
			]

				
	