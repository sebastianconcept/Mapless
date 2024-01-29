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

{ #category : #actions }
MaplessMemoryRepositoryTest >> addDummyPeople [
	| guy |
	1 to: 10 do: [ :i | 
		guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
		i > 1
			ifTrue: [ guy lastName: guy lastName , i asString ].
		guy save ].
	1 to: 10 do: [ :i | 
		guy := DummyPerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
		i > 1
			ifTrue: [ guy firstName: guy firstName , i asString ].
		guy save ]
]

{ #category : #actions }
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
		using: MaplessMemoryCollectionToClassNameResolver new
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
		using: MaplessMemoryCollectionToClassNameResolver new
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testAccessorDatabaseAccess [
	| db |
	db := repository database.
	self assert: db class equals: MaplessMemoryDatabase.
	self assert: db databaseName equals: 'Mapless-Test'
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testCursorCount [
	repository
		do: [ self addDummyPeople.
			self assert: DummyPerson count equals: 20 ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testCursorCountWithConditions [
	repository
		do: [ self addDummyPeople.
			self
				assert: (DummyPerson count: [ :each | each firstName = 'john' ])
				equals: 10 + 1 ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDatabaseCollection [
	| db databaseCollection |
	db := repository database.
	databaseCollection := db collectionNamed: 'Things'.
	self assert: databaseCollection name equals: 'Things'.
	self assert: databaseCollection isEmpty
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
			guy save ].
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
				collect: [ :name | self newDummyPersonNamed: name ].
			guys do: #save.
			guy := DummyPerson find: [ :each | each firstName = 'John' ].
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
			guy save ].
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
			guy save.
			self assert: (databaseCollection includes: guy).
			guy destroy ].
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

{ #category : #tests }
MaplessMemoryRepositoryTest >> testDropDatabase [

	| db databaseCollection |
	db := repository database.
	repository do: [ self addDummyPeople ].
	databaseCollection := db collectionNamed: 'DummyPerson'.
	self assert: databaseCollection name equals: 'DummyPerson'.
	self deny: repository database collections isEmpty.

	self shouldnt: [ repository drop ] raise: Error.
	self assert: repository database collections isEmpty
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testExistenceDetection [

	| all |
	repository do: [
		self addDummyPeople.
		all := DummyPerson findAll ].

	self deny: (repository existsId: '123' of: DummyPerson).
	all do: [ :guy |
		self assert: (repository existsId: guy id of: DummyPerson) ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testFindAll [
	| found |
	repository
		do: [ self addDummyPeople.
			found := DummyPerson findAll.
			self assert: found notNil.
			self assert: found size equals: 20 ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testFindAllSorted [
	| found |
	repository
		do: [ (self newDummyPersonNamed: 'Peter') save.
			(self newDummyPersonNamed: 'Robert') save.
			(self newDummyPersonNamed: 'John') save.
			found := DummyPerson findAllSort: #firstName ascending.
			self assert: found notNil.
			self assert: found size equals: 3.
			self assert: found notNil.
			self assert: found first firstName = 'John'.
			self assert: found last firstName = 'Robert' ]
]

{ #category : #tests }
MaplessMemoryRepositoryTest >> testSelectWithSort [
	| found |
	repository
		do: [ self addDummyPeople.
			found := DummyPerson
				find: [ :each | each firstName = 'john' | (each firstName = 'john3') ]
				sort: #firstName ascending.
			self assert: found notNil.
			self assert: found size equals: 1 + 10 + 1.
			self assert: found first firstName = 'john'.
			self assert: found last firstName = 'john3' ]
]
