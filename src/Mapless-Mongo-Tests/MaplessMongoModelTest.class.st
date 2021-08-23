Class {
	#name : #MaplessMongoModelTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'mongoRepository'
	],
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #actions }
MaplessMongoModelTest >> do: aBlock [ 

	^mongoRepository do: aBlock
]

{ #category : #'setUp-tearDown' }
MaplessMongoModelTest >> setUp [

	super setUp.
	mongoRepository := MaplessMongoRepository for: 'Mapless-Tests'
]

{ #category : #'setUp-tearDown' }
MaplessMongoModelTest >> tearDown [

	super tearDown.
	mongoRepository := nil
]

{ #category : #tests }
MaplessMongoModelTest >> testDeleteHook [

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeDelete isNil.
	self assert: user afterDelete isNil.
	
	self do: [ user save ]. 

	self do: [ 
		user delete. 
		self assert: user isDeleted ].
	
	self assert: user beforeDelete.
	self assert: user afterDelete.
	
]

{ #category : #tests }
MaplessMongoModelTest >> testDestroyHook [

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeDestroy isNil.
	self assert: user afterDestroy isNil.
	
	self do: [ user save ]. 
	self do: [ user destroy ].
	
	self assert: user beforeDestroy.
	self assert: user afterDestroy.
	
]

{ #category : #tests }
MaplessMongoModelTest >> testInsertHook [

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeInsert isNil.
	self assert: user afterInsert isNil.
	
	self do: [ user insert ].
	
	self assert: user beforeInsert.
	self assert: user afterInsert.
	
]

{ #category : #tests }
MaplessMongoModelTest >> testMergeComposed [

	| user guy newerUser newerGuy |

	self do: [ 
	user := DummyUser new
			username: 'johnq';
			yourself.

	guy := DummyPerson new
			firstName: 'John';
			yourself.

	user person: guy.
	
	newerUser := DummyUser new
			email: 'johnq@email';
			yourself.

	newerGuy := DummyPerson new
			firstName: 'JohM';
			lastName: 'Q';
			yourself.
	newerUser person: newerGuy.

	user merge: newerUser.

	self assert: newerUser username isNil.
	self deny: user person firstName = 'JohM'.

	self assert: user email notNil.
	self assert: user email = newerUser email.
	self assert: user person firstName = 'John'.	
	self assert: user person lastName = 'Q']	
]

{ #category : #tests }
MaplessMongoModelTest >> testMergeSimple [

	| user newerUser|

	user := DummyUser new
			username: 'johnq';
			yourself.

	newerUser := DummyUser new
			email: 'johnq@email';
			yourself.

	self assert: user email isNil.
	self assert: newerUser username isNil.

	user merge: newerUser.

	self assert: user email notNil.
	self assert: user email = newerUser email.
	self assert: newerUser username isNil.
	
]

{ #category : #tests }
MaplessMongoModelTest >> testReifyWithoutMetadata [

	| user serializedWith serializedWithout |

	user := DummyPerson new
			firstName: 'john';
			yourself.

	serializedWith := '{"id": "abc123", "modelClass": "DummyPerson","createdOn": "2017-01-22T13:49:37.564031+00:00","firstName": "john"}'.
	
	serializedWithout :=  '{"id": "abc123", "createdOn": "2017-01-22T13:49:37.564031+00:00","firstName": "john"}'.
	
	self do:[ 
		self assert: (DummyPerson fromJSONString: serializedWith) class == DummyPerson.
		self assert: (DummyPerson fromJSONString: serializedWithout) class == DummyPerson.

		self assert: (DummyUser fromJSONString: serializedWithout) class == DummyUser.
	]
]

{ #category : #tests }
MaplessMongoModelTest >> testSaveHook [

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeSave isNil.
	self assert: user afterSave isNil.
	
	self do: [ user save ].
	
	self assert: user beforeSave.
	self assert: user afterSave.
	
]

{ #category : #tests }
MaplessMongoModelTest >> testUnrefDestroy [

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


]

{ #category : #tests }
MaplessMongoModelTest >> testUnrefDestroy2 [

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
	
	self do: [friends do: [:e | e save]].
	self do:[guy save].
	self deny: guy isUnsaved.
	
	self do:[ loaded := DummyPerson findId: guy id].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data friends class = OrderedCollection.
	self do: [ reified destroy].

	"By design, the destruction should be to the individual aggregate (and not its submodels).
	It's programmers' responsability to decide when to destroy a sub aggregate"	
	self assert: ( self do: [ reloaded := DummyPerson existsId: loaded id]) not.	
	self do:[self assert: ((friends collect: [:e| e id]) allSatisfy: [:guyId|
					(DummyPerson existsId: guyId)])]
			]

				
	
]

{ #category : #tests }
MaplessMongoModelTest >> testUnreferenced [
	"Tests MaplessMongoModel>>#unreferenced"
	| person tagsCollection loaded reified |
	
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
	tagsCollection do: [:e | self do: [ e save ] ].
	
	self do:[ person save ].
	self deny: person isUnsaved.
	
	self do:[ loaded := DummyPerson findId: person id].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data tags class = OrderedCollection.
	self assert: (reified data tags first class = MaplessReference) not. 
	self assert: (reified data tags second class = MaplessReference) not.
	
	self assert: reified data tags first isCustomer.
	self assert: (reified data tags second isComplicated = false)]
]

{ #category : #tests }
MaplessMongoModelTest >> testUnreferenced2 [

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
	
	friends do: [:e | self do:[ e save]].
	self do:[guy save].
	self deny: guy isUnsaved.
	
	self do:[ loaded := DummyPerson findId: guy id].
	
	self assert: loaded notNil.
	self deny: loaded isUnsaved.
	
	self do: [ reified := loaded unreferenced ].

	self assert: reified data friends class = OrderedCollection.
	self assert: reified data favorites = stuff]
				
	
]

{ #category : #tests }
MaplessMongoModelTest >> testUpdatetHook [

	| user |

	user := DummyUser new
			username: 'johnq';
			yourself.

	self assert: user beforeUpdate isNil.
	self assert: user afterUpdate isNil.
	
	self do: [ 
			user save.
			user save. ]. 
	
	self assert: user beforeUpdate.
	self assert: user afterUpdate.
	
]
