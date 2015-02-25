tests
testUnrefDestroy

	"Tests MaplessMongoModel>>#unreferenced"
	| person tagsCollection loaded reified reloaded |
	
	self do: [ 
	tagsCollection := OrderedCollection new
		 add: (DummyTag new
			isCustomer: true;
			yourself);
		add: (DummyTag new
			isComplicated: false;
			yourself); 
		yourself.
			
	person := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
	"Save all tags in the collection"
	person tags: tagsCollection.
	self assert: person isUnsaved.
	"save tagsCollection"	

	tagsCollection do: [:e | e save].
	
	person save.
	self deny: person isUnsaved.
	
	
	loaded := DummyPerson findId: person id.

	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	reified := loaded unreferenced.

	self assert: reified data tags class = OrderedCollection.
	self assert: (reified data tags first class = MaplessReference) not. 
	self assert: (reified data tags second class = MaplessReference) not.
	
	self assert: reified data tags first isCustomer.
	self assert: (reified data tags second isComplicated = false).
	
	reified destroy.
	"self do: [ loaded destroy].
	"
	self assert: ( reloaded := DummyPerson existsId: reified id) not]

