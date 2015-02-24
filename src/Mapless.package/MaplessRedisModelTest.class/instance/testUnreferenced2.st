tests
testUnreferenced2

	| friends guy stuff loaded reified | 
	
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
				
	stuff := #('Ice cream' 'waffles' 'french fries') asOrderedCollection.
	
	guy := DummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
	
	friends do: [:e |  e save].
	guy save.
	self deny: guy isUnsaved.
	
	loaded := DummyPerson findId: guy id.
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	reified := loaded unreferenced.

	self assert: reified data friends class = OrderedCollection.
	self assert: reified data favorites = stuff.
				
	]