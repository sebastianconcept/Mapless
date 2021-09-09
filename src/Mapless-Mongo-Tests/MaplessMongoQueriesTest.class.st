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

{ #category : #'setUp-tearDown' }
MaplessMongoQueriesTest >> setUp [
	super setUp.
	repository := MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessMongoPool local
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
			self assert: DummyPerson count equals: 20 ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testCursorCountWithConditions [
	repository
		do: [ self addDummyPeople.
			self
				assert: (DummyPerson count: {('firstName' -> 'john')} asDictionary)
				equals: 10 +1 ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testSelectWithAnd [
	| found |
	repository
		do: [ self addDummyPeople.
			found := DummyPerson
				findOne: [ :each | each firstName = 'john' & (each lastName = 'q4') ].
			self assert: found notNil.
			self assert: found firstName equals: 'john'.
			self assert: found lastName equals: 'q4' ]
]

{ #category : #tests }
MaplessMongoQueriesTest >> testSelectWithOr [
	| found |
	repository
		do: [ self addDummyPeople.
			found := DummyPerson
				find: [ :each | each firstName = 'john' | (each firstName = 'john3') ].
			self assert: found notNil.
			self assert: found size equals: 1 + 10 + 1.
			self assert: (found anySatisfy: [ :e | e firstName = 'john' ]).
			self assert: (found anySatisfy: [ :e | e firstName = 'john3' ]) ]
]
