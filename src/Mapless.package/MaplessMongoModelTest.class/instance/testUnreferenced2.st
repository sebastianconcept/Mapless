tests
testUnreferenced2

	| friends guy stuff loaded reified | 
	
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
				
	stuff := #('Ice cream' 'waffles' 'french fries') asOrderedCollection.
	
	guy := MaplessMongoDummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
	
	friends do: [:e | self do:[ e save]].
	self do:[guy save].
	self deny: guy isUnsaved.
	
	self do:[ loaded := MaplessMongoDummyPerson findAt: guy oid].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data friends class = OrderedCollection.
	self assert: reified data favorites = stuff.
				
	