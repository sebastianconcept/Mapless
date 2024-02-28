Class {
	#name : #MaplessMongoQueriesTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #tests }
MaplessMongoQueriesTest >> addDummyPeople [
	| guy |
	1 to: 10 do: [ :i | 
		guy := SamplePerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
		i > 1
			ifTrue: [ guy lastName: guy lastName , i asString ].
		guy save ].
	1 to: 10 do: [ :i | 
		guy := SamplePerson new
			firstName: 'john';
			lastName: 'q';
			yourself.
		i > 1
			ifTrue: [ guy firstName: guy firstName , i asString ].
		guy save ]
]

{ #category : #'setUp-tearDown' }
MaplessMongoQueriesTest >> setUp [
	super setUp.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessStandaloneMongoPool local
]

{ #category : #'setUp-tearDown' }
MaplessMongoQueriesTest >> tearDown [
	super tearDown.
	repository
		drop;
		shutDown
]

{ #category : #tests }
MaplessMongoQueriesTest >> testCursorCount [
	repository
		do: [ self addDummyPeople.
			self assert: SamplePerson count equals: SamplePerson findAll size ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testCursorCountWithConditions [
	repository
		do: [ self addDummyPeople.
			self
				assert: (SamplePerson count: {('firstName' -> 'john')} asDictionary)
				equals: 10 + 1.
			self
				deny: (SamplePerson count: {('firstName' -> 'john')} asDictionary)
				equals: SamplePerson findAll size ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testFindAll [
	| found |
	repository
		do: [ self addDummyPeople.
			found := SamplePerson findAll.
			self assert: found notNil.
			self assert: found size equals: 20 ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testFresh [
	| found guy freshGuy |
	repository
		do: [ self addDummyPeople.
			found := SamplePerson findAll.
			self assert: found notNil.
			self assert: found size equals: 20 ].
	guy := found first.
	self assert: guy hasId.
	self assert: (guy maplessData at: 'id') notNil.
	guy remember: #this.
	repository
		do: [ freshGuy := guy fresh.
			self assert: freshGuy id equals: guy id.
			self deny: freshGuy rememer equals: #this.
			self deny: guy hash equals: freshGuy hash ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testSelectWithAnd [
	| found |
	repository
		do: [ self addDummyPeople.
			found := SamplePerson
				find: [ :each | each firstName = 'john' & (each lastName = 'q4') ].
			self assert: found notEmpty.
			self assert: found size equals: 1.
			self assert: found first firstName equals: 'john'.
			self assert: found first lastName equals: 'q4' ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testSelectWithOr [
	| found |
	repository
		do: [ self addDummyPeople.
			found := SamplePerson
				find: [ :each | each firstName = 'john' | (each firstName = 'john3') ].
			self assert: found notNil.
			self assert: found size equals: 1 + 10 + 1.
			self assert: (found anySatisfy: [ :e | e firstName = 'john' ]).
			self assert: (found anySatisfy: [ :e | e firstName = 'john3' ]) ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testSelectWithSort [
	| found |
	repository
		do: [ self addDummyPeople.
			found := SamplePerson
				find: [ :each | each firstName = 'john' | (each firstName = 'john3') ]
				sort: {('firstName' -> 1)} asDictionary.
			self assert: found notNil.
			self assert: found size equals: 1 + 10 + 1.
			self assert: found first firstName = 'john'.
			self assert: found last firstName = 'john3' ]
]
