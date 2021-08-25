Class {
	#name : #MaplessMongoMultiRepositoryTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repositories'
	],
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #running }
MaplessMongoMultiRepositoryTest >> setUp [
	super setUp.
	repositories := Dictionary new
]

{ #category : #running }
MaplessMongoMultiRepositoryTest >> tearDown [
	repositories valuesDo: [ :repo | repo drop; shutDown ].
	super tearDown
]

{ #category : #running }
MaplessMongoMultiRepositoryTest >> testConnectTwoDatabases [
	| repo1 repo2 |
	repo1 := MaplessMongoRepository
		for: 'Mapless-Test1'
		with: MaplessMongoPool local.
	repo2 := MaplessMongoRepository
		for: 'Mapless-Test2'
		with: MaplessMongoPool local.
	repositories at: 1 put: repo1.
	repositories at: 2 put: repo2
]

{ #category : #running }
MaplessMongoMultiRepositoryTest >> testSaveToAndReadFromTwoDatabases [
	| repo1 repo2 guy found |
	repo1 := MaplessMongoRepository
		for: 'Mapless-Test1'
		with: MaplessMongoPool local.
	repo2 := MaplessMongoRepository
		for: 'Mapless-Test2'
		with: MaplessMongoPool local.
	repositories at: 1 put: repo1.
	repositories at: 2 put: repo2.
	repo1
		do: [ guy := DummyPerson new
				firstName: 'john';
				lastName: 'q';
				yourself.
			self assert: guy isUnsaved.
			guy save.
			self deny: guy isUnsaved ].
	repo1
		do: [ found := DummyPerson findId: guy id.
			self assert: found notNil.
			self assert: found firstName equals: guy firstName ].
	repo2
		do: [ guy := DummyPerson new
				firstName: 'peter';
				lastName: 'e';
				yourself.
			self assert: guy isUnsaved.
			guy save.
			self deny: guy isUnsaved ].
	repo2
		do: [ found := DummyPerson findId: guy id.
			self assert: found notNil.
			self assert: found firstName equals: guy firstName ]
]

{ #category : #running }
MaplessMongoMultiRepositoryTest >> testStartStopPool [
	| repo1 repo2 |
	repo1 := MaplessMongoRepository
		for: 'Mapless-Test1'
		with: MaplessMongoPool local.
	repo2 := MaplessMongoRepository
		for: 'Mapless-Test2'
		with: MaplessMongoPool local.
	repositories at: 1 put: repo1.
	repositories at: 2 put: repo2.
	repo1 startUp: 5.
	repo2 startUp: 3.
	self assert: repo1 accessor idleClients size equals: 5.
	self assert: repo2 accessor idleClients size equals: 3.
	repo1 shutDown.
	repo2 shutDown.
	self
		assert: (repo1 accessor allClients allSatisfy: [ :e | e isOpen not ]).
	self
		assert: (repo2 accessor allClients allSatisfy: [ :e | e isOpen not ])
]
