tests
testUnrefDestroy

	"Tests MaplessMongoModel>>#unreferenced"
	| person tagsCollection loaded reified reloaded |
	
	tagsCollection := OrderedCollection new
		 add: (MaplessRedisDummyTag new
			isCustomer: true;
			yourself);
		add: (MaplessRedisDummyTag new
			isComplicated: false;
			yourself); 
		yourself.
			
	person := MaplessRedisDummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	"Save all tags in the collection"
	person tags: tagsCollection.
	self assert: person isUnsaved.
	"save tagsCollection"	
	tagsCollection do: [:e | self do:[ e save]].
	
	self do:[person save].
	self deny: person isUnsaved.
	
	self do:[ loaded := MaplessRedisDummyPerson findAt: person oid].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data tags class = OrderedCollection.
	self assert: (reified data tags first class = MaplessReference) not. 
	self assert: (reified data tags second class = MaplessReference) not.
	
	self assert: reified data tags first isCustomer.
	self assert: (reified data tags second isComplicated = false).
	
	self do: [ reified destroy].
	"self do: [ loaded destroy].
	"
	self assert: ( self do: [ reloaded := MaplessRedisDummyPerson existsAt: reified oid]) not.	

