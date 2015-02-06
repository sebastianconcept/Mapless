tests
testUnreferenced2

	| friends guy stuff loaded reified | 
	
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
				
	stuff := #('Ice cream' 'waffles' 'french fries') asOrderedCollection.
	
	guy := MaplessDummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
	
	friends do: [:e | self do:[ e save]].
	self do:[guy save].
	self deny: guy isUnsaved.
	
	self do:[ loaded := MaplessDummyPerson findId: guy id].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data friends class = OrderedCollection.
	self assert: reified data favorites = stuff]
				
	