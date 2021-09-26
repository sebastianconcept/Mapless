Class {
	#name : #MaplessMongoModelTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #accessing }
MaplessMongoModelTest >> currentRepository [
	^ MaplessCurrentRepository value
]

{ #category : #actions }
MaplessMongoModelTest >> do: aBlock [
	^ repository do: aBlock
]

{ #category : #'setUp-tearDown' }
MaplessMongoModelTest >> setUp [
	super setUp.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessMongoPool local
]

{ #category : #'setUp-tearDown' }
MaplessMongoModelTest >> tearDown [
	super tearDown.
	repository
		drop;
		shutDown
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
	self
		do: [ user delete.
			self assert: user isDeleted ].
	self assert: user beforeDelete.
	self assert: user afterDelete
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
	self assert: user afterDestroy
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
	self assert: user afterInsert
]

{ #category : #tests }
MaplessMongoModelTest >> testMergeComposed [
	| user guy newerUser newerGuy |
	self
		do: [ user := DummyUser new
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
			self assert: user person lastName = 'Q' ]
]

{ #category : #tests }
MaplessMongoModelTest >> testMergeSimple [
	| user newerUser |
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
	self assert: newerUser username isNil
]

{ #category : #tests }
MaplessMongoModelTest >> testRaiseErrorWhenTryingToInsertADuplicatedUnique [
	| user |
	user := DummyUser new
		username: 'johnq';
		yourself.
	self
		do: [ user insert.
			self should: [ user insert ] raise: MongoCommandError.
			[ user insert ]
				on: MongoCommandError
				do: [ :x | self assert: x isInsertionError ] ]
]

{ #category : #tests }
MaplessMongoModelTest >> testRaiseErrorWhenTryingToSaveADuplicatedUnique [
	| john peter |
	repository
		do: [ repository database
				command:
					{('createIndexes' -> DummyPerson collectionName).
					('indexes'
						->
							{{('key' -> {('lastName' -> 1)} asDictionary).
							('name' -> 'lastName_unique').
							('unique' -> true)} asDictionary})} asOrderedDictionary ].
	john := DummyPerson new
		firstName: 'John';
		lastName: 'Someson';
		yourself.
	peter := DummyPerson new
		firstName: 'Peter';
		lastName: 'Someson';
		yourself.
	self
		do: [ john save.
			self should: [ john insert ] raise: MongoCommandError.
			[ john insert ]
				on: MongoCommandError
				do: [ :x | self assert: x isInsertionError ].
			[ peter insert ]
				on: MongoCommandError
				do: [ :x | self assert: x isInsertionError ] ]
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
	self assert: user afterSave
]

{ #category : #tests }
MaplessMongoModelTest >> testUnrefDestroy [
	"Tests MaplessMongoModel>>#unreferenced"

	| person tagsCollection loaded reified reloaded |
	self
		do: [ tagsCollection := OrderedCollection new
				add:
					(DummyTag new
						isCustomer: true;
						yourself);
				add:
					(DummyTag new
						isComplicated: false;
						yourself);
				yourself.
			person := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			"Save all tags in the collection"
			person tags: tagsCollection.
			"save tagsCollection"
			tagsCollection do: [ :e | e save ].
			person save.
			loaded := DummyPerson findId: person id.
			self assert: loaded notNil.
			reified := loaded unreferenced.
			self assert: reified maplessData tags class = OrderedCollection.
			self
				assert: (reified maplessData tags first class = MaplessReference) not.
			self
				assert: (reified maplessData tags second class = MaplessReference) not.
			self assert: reified maplessData tags first isCustomer.
			self assert: reified maplessData tags second isComplicated = false.
			reified destroy.
			"loaded destroy"
			self assert: (reloaded := DummyPerson existsId: reified id) not ]
]

{ #category : #tests }
MaplessMongoModelTest >> testUnrefDestroy2 [
	| friends guy stuff loaded reified reloaded |
	self
		do: [ friends := OrderedCollection new
				add:
					(DummyPerson new
						firstName: 'Frodo';
						yourself);
				add:
					(DummyPerson new
						firstName: 'Gandalf';
						yourself);
				add:
					(DummyPerson new
						firstName: 'Boromir';
						yourself);
				yourself.
			stuff := #('Ice cream' 'waffles' 'french fries').
			guy := DummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
			self do: [ friends do: [ :e | e save ] ].
			self do: [ guy save ].
			self do: [ loaded := DummyPerson findId: guy id ].
			self assert: loaded notNil.
			self do: [ reified := loaded unreferenced ].
			self assert: reified data friends class = OrderedCollection.
			self do: [ reified destroy ].

			"By design, the destruction should be to the individual aggregate (and not its submodels).
	It's programmers' responsability to decide when to destroy a sub aggregate"
			self
				assert: (self do: [ reloaded := DummyPerson existsId: loaded id ]) not.
			self
				do: [ self
						assert:
							((friends collect: [ :e | e id ])
								allSatisfy: [ :guyId | DummyPerson existsId: guyId ]) ] ]
]

{ #category : #tests }
MaplessMongoModelTest >> testUnreferenced [
	"Tests MaplessMongoModel>>#unreferenced"

	| person tagsCollection loaded reified |
	self
		do: [ tagsCollection := OrderedCollection new
				add:
					(DummyTag new
						isCustomer: true;
						yourself);
				add:
					(DummyTag new
						isComplicated: false;
						yourself);
				yourself.
			person := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.

			"Save all tags in the collection"
			person tags: tagsCollection.
			"save tagsCollection"
			tagsCollection do: [ :e | self do: [ e save ] ].
			self do: [ person save ].
			self do: [ loaded := DummyPerson findId: person id ].
			self assert: loaded notNil.
			self do: [ reified := loaded unreferenced ].
			self assert: reified data tags class = OrderedCollection.
			self assert: (reified data tags first class = MaplessReference) not.
			self
				assert: (reified data tags second class = MaplessReference) not.
			self assert: reified data tags first isCustomer.
			self assert: reified data tags second isComplicated = false ]
]

{ #category : #tests }
MaplessMongoModelTest >> testUnreferenced2 [
	| friends guy stuff loaded reified |
	self
		do: [ friends := OrderedCollection new
				add:
					(DummyPerson new
						firstName: 'Frodo';
						yourself);
				add:
					(DummyPerson new
						firstName: 'Gandalf';
						yourself);
				add:
					(DummyPerson new
						firstName: 'Boromir';
						yourself);
				yourself.
			stuff := #('Ice cream' 'waffles' 'french fries')
				asOrderedCollection.
			guy := DummyPerson new
				firstName: 'dude';
				favorites: stuff;
				friends: friends;
				yourself.
			friends do: [ :e | self do: [ e save ] ].
			self do: [ guy save ].
			self do: [ loaded := DummyPerson findId: guy id ].
			self assert: loaded notNil.
			self do: [ reified := loaded unreferenced ].
			self assert: reified data friends class = OrderedCollection.
			self assert: reified data favorites = stuff ]
]

{ #category : #tests }
MaplessMongoModelTest >> testUpdatetHook [
	| user |
	user := DummyUser new
		username: 'johnq';
		yourself.
	self assert: user beforeUpdate isNil.
	self assert: user afterUpdate isNil.
	self
		do: [ user insert.
			user update ].
	self assert: user beforeUpdate.
	self assert: user afterUpdate
]

{ #category : #tests }
MaplessMongoModelTest >> testUpsertHook [
	| user |
	user := DummyUser new
		username: 'johnq';
		yourself.
	self assert: user beforeUpsert isNil.
	self assert: user afterUpsert isNil.
	self do: [ user save ].
	self assert: user beforeUpsert.
	self assert: user afterUpsert
]

{ #category : #actions }
MaplessMongoModelTest >> withClientDo: aBlock [
	^ repository withClientDo: aBlock
]
