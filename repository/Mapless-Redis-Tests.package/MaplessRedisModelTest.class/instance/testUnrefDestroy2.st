tests
testUnrefDestroy2

	| friends guy stuff loaded reified  | 
	
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
	
	self do: [
		friends do: [:e | e save].
		guy save.
		self deny: guy isUnsaved ].
	
	self do:[ loaded := DummyPerson findId: guy id].
	
	self assert: loaded notNil.
	self do: [ 
		self deny: loaded isUnsaved.
		reified := loaded unreferenced.
		].
	

	self assert: reified data friends class = OrderedCollection.
	self do: [ reified destroy ].

	"By design, the destruction should be to the individual aggregate (and not its submodels).
	It's programmers' responsability to decide when to destroy a sub aggregate"	
	self do: [
		self deny: (DummyPerson findId: reified id) notNil.
		self deny: (DummyPerson existsId: reified id).
		self assert: ((friends collect: [ :e | e id ]) allSatisfy: [ :guyId |
					(DummyPerson existsId: guyId)]) ]