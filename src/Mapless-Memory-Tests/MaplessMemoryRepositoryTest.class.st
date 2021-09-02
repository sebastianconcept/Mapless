"
This class contains unit tests for the MaplessMemoryRepository
"
Class {
	#name : #MaplessMemoryRepositoryTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Memory-Tests'
}

{ #category : #tests }
MaplessMemoryRepositoryTest >> newDummyPersonNamed: aString [
	^ DummyPerson new
		firstName: aString;
		yourself
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> setUp [
	super setUp.
	repository := MaplessMemoryRepository
		for: 'Mapless-Test'
		with: MaplessMemoryAccessor new
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> tearDown [
	repository ifNotNil: [ repository shutDown ].
	super tearDown
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testAccessorCreation [
	| repo |
	repo := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessMemoryAccessor new
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testAccessorDatabaseAccess [
	| db |
	db := repository database.
	self assert: db class equals: MaplessMemoryDatabase.
	self assert: db databaseName equals: 'Mapless-Test'
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseCollection [
	| db databaseCollection |
	db := repository database.
	databaseCollection := db collectionNamed: 'Things'.
	self assert: databaseCollection name equals: 'Things'.
	self assert: databaseCollection isEmpty.
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseCollectionFindId [
	| db databaseCollection guy |
	db := repository database.
	databaseCollection := db collectionNamed: 'DummyPerson'.
	self assert: databaseCollection isEmpty.
	repository
		do: [ guy := DummyPerson new
				firstName: 'John';
				lastName: 'Q';
				yourself.
			self assert: guy isUnsaved.
			guy save.
			self assert: guy isUnsaved not ].
	self assert: (databaseCollection includes: guy).
	repository
		do: [ self assert: (DummyPerson findId: guy id) notNil.
			self assert: (DummyPerson findId: guy id) firstName equals: 'John' ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseCollectionFindOneWithConditions [
	| db databaseCollection guys guy |
	db := repository database.
	databaseCollection := db collectionNamed: 'DummyPerson'.
	self assert: databaseCollection isEmpty.
	repository
		do: [ guys := {'John' . 'Peter' . 'Dave'}
				collect: [ :name | (self newDummyPersonNamed: name) save ] ].
	repository
		do: [ guy := DummyPerson findOne: [ :each | each firstName = 'Dave' ].
			self assert: guy firstName equals: 'Dave' ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseCollectionFindWithConditions [
	| db databaseCollection guys guy |
	db := repository database.
	databaseCollection := db collectionNamed: 'DummyPerson'.
	self assert: databaseCollection isEmpty.
	repository
		do: [ guys := {'John' . 'Peter' . 'Dave'}
				collect: [ :name | (self newDummyPersonNamed: name) save ] ].
	repository
		do: [ guy := DummyPerson find: [ :each | each firstName = 'John' ].
			guys detect: [ :e | e firstName = 'John' ].
			self assert: guys first firstName equals: 'John' ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseCollectionSave [
	| db databaseCollection guy |
	db := repository database.
	databaseCollection := db collectionNamed: 'DummyPerson'.
	self assert: databaseCollection isEmpty.
	repository
		do: [ guy := DummyPerson new
				firstName: 'John';
				lastName: 'Q';
				yourself.
			self assert: guy isUnsaved.
			guy save.
			self assert: guy isUnsaved not].
		
	self assert: (databaseCollection includes: guy)
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseCollectionSaveAndDestroy [
	| db databaseCollection guy |
	db := repository database.
	databaseCollection := db collectionNamed: 'DummyPerson'.
	repository
		do: [ guy := DummyPerson new
				firstName: 'John';
				lastName: 'Q';
				yourself.
			guy save ].
	self assert: (databaseCollection includes: guy).
	repository do: [ guy destroy ].
	self deny: (databaseCollection includes: guy).
	self assert: databaseCollection isEmpty
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseDrop [
	| db databaseCollection |
	db := repository database.
	databaseCollection := db collectionNamed: 'Things'.
	self deny: db collections isEmpty.
	self assert: databaseCollection name equals: 'Things'.
	db drop.
	self assert: db collections isEmpty
]
