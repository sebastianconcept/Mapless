"
Coverage for MongoChages features
"
Class {
	#name : #MaplessMongoChangeTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository',
		'logRepository',
		'observer'
	],
	#category : #'Mapless-Mongo-Log-Tests'
}

{ #category : #history }
MaplessMongoChangeTest class >> maplessClasses [
	^ {DummyPerson.
	DummyUser.
	DummyTag.
	MongoChange.
	MongoChangeSequence}
]

{ #category : #running }
MaplessMongoChangeTest >> newRepository [
	^ MaplessMongoRepository
		for: 'Mapless-Test'
		with: MaplessStandaloneMongoPool local
]

{ #category : #running }
MaplessMongoChangeTest >> resetDatabase [
	"Remove all objects so the database is clean for any test to be run."

	self class maplessClasses do: [ :each | 
		repository destroyAll: each.
		logRepository destroyAll: each ]
]

{ #category : #running }
MaplessMongoChangeTest >> setUp [
	super setUp.
	repository := self newRepository.
	logRepository := self newRepository.
	self resetDatabase.
	observer := MaplessMongoObserver
		on: repository
		loggingIn: logRepository
]

{ #category : #running }
MaplessMongoChangeTest >> tearDown [
	super tearDown.
	repository accessor stop.
	logRepository accessor stop.
	observer := nil.
	repository := nil.
	logRepository := nil
]

{ #category : #running }
MaplessMongoChangeTest >> testDoubleUpdateLog [
	| guy mongoChange expectation serializedUpdated |
	logRepository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	self assert: (logRepository count: MongoChange) equals: 0.
	repository save: guy.
	self assert: (logRepository count: MongoChange) equals: 1.
	self
		assert: (logRepository findAll: MongoChange) first type
		equals: #insert asUppercase.
	self
		assert: (logRepository findAll: MongoChange) first sequenceNumber
		equals: 1.
	guy lastName: 'Q'.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self
		assert:
			((logRepository findAll: MongoChange)
				detect: [ :e | e type = #update asUppercase ]
				ifNone: [ nil ]) notNil.
	self
		assert:
			((logRepository findAll: MongoChange)
				detect: [ :e | e type = #update asUppercase ]) sequenceNumber
		equals: 2.
	self assert: (repository existsId: guy id of: DummyPerson).

	"Change the maplesss object"
	guy
		firstName: 'John';
		profession: 'Carpenter';
		yourself.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self assert: (repository existsId: guy id of: DummyPerson).
	self assert: (logRepository count: MongoChange) equals: 3.
	mongoChange := (logRepository
		findAll: MongoChange
		sort: {(#sequenceNumber -> -1)} asDictionary)
		detect: [ :e | e type = #update asUppercase ].
	self assert: mongoChange mongoCommand notNil.
	self assert: mongoChange type equals: #update asUppercase.
	serializedUpdated := '\{"_c":"DummyPerson","lastName":"Q","_id":ObjectId("{1}"),"modifiedOn":ISODate("{2}"),"firstName":"John","profession":"Carpenter"\}'
		format:
			{(guy id value hex allButFirst: 3) asLowercase.
			guy modifiedOn asString}.
	expectation := 'db.DummyPerson.updateOne(\{"_id": ObjectId("{1}")\},\{$set:{2}\})'
		format:
			{(guy id value hex allButFirst: 3) asLowercase.
			serializedUpdated}.
	self assert: mongoChange mongoCommand equals: expectation
]

{ #category : #running }
MaplessMongoChangeTest >> testSequenceNumber [
	| guy |
	logRepository := self newRepository.
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self assert: (logRepository count: MongoChange) equals: 1.
	self assert: (repository existsId: guy id of: DummyPerson).
	self
		assert: (logRepository findAll: MongoChange) first sequenceNumber
		equals: 1.

	"Change the maplesss object"
	guy
		firstName: 'John';
		lastName: 'Q';
		profession: 'Carpenter';
		yourself.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self assert: (repository existsId: guy id of: DummyPerson).
	self assert: (logRepository count: MongoChange) equals: 2.
	self assert: (logRepository count: MongoChangeSequence) equals: 1.
	self
		assert: (logRepository findAll: MongoChangeSequence) first last
		equals: 3.
	guy lastName: 'Quarantino'.
	repository save: guy.
	self
		assert: (logRepository findAll: MongoChangeSequence) first last
		equals: 4.
	guy profession: 'Antiques carpenter'.
	repository save: guy.
	self
		assert: (logRepository findAll: MongoChangeSequence) first last
		equals: 5.
	self assert: (logRepository count: MongoChangeSequence) equals: 1
]

{ #category : #running }
MaplessMongoChangeTest >> testSimpleDeleteLog [
	| guy mongoChange expectation |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self assert: (logRepository count: MongoChange) equals: 1.
	self assert: (repository existsId: guy id of: DummyPerson).
	repository destroy: guy.
	self assert: (repository count: DummyPerson) equals: 0.
	self deny: (repository existsId: guy id of: DummyPerson).
	self assert: (logRepository count: MongoChange) equals: 2.
	mongoChange := (logRepository findAll: MongoChange)
		detect: [ :e | e type = #delete asUppercase ].
	expectation := 'db.DummyPerson.deleteOne(\{"_id": ObjectId("{1}")\})'
		format: {(guy id value hex allButFirst: 3) asLowercase}.
	self assert: mongoChange mongoCommand notNil.
	self assert: mongoChange type equals: #delete asUppercase.
	self assert: mongoChange mongoCommand equals: expectation
]

{ #category : #running }
MaplessMongoChangeTest >> testSimpleInsertLog [
	| guy mongoChange expectation |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	self assert: (logRepository count: MongoChange) equals: 1.
	mongoChange := (logRepository findAll: MongoChange) first.
	expectation := 'db.DummyPerson.insertOne(\{"_c":"DummyPerson","lastName":"q","_id":ObjectId("{1}"),"modifiedOn":ISODate("{2}"),"firstName":"john"\})'
		format:
			{(guy id value hex allButFirst: 3) asLowercase.
			guy modifiedOn asString}.
	self assert: mongoChange mongoCommand notNil.
	self assert: mongoChange type equals: #insert asUppercase.
	self assert: mongoChange document notNil.
	self assert: mongoChange mongoCommand equals: expectation
]

{ #category : #running }
MaplessMongoChangeTest >> testSimpleUpdateLog [
	| guy mongoChange expectation serializedUpdated |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self assert: (logRepository count: MongoChange) equals: 1.
	self
		assert:
			(logRepository
				count: MongoChange
				where: {(#type -> #insert asUppercase)} asDictionary)
		equals: 1.
	self assert: (repository existsId: guy id of: DummyPerson).

	"Change the maplesss object"
	guy
		firstName: 'John';
		lastName: 'Q';
		profession: 'Carpenter';
		yourself.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self assert: (repository existsId: guy id of: DummyPerson).
	self assert: (logRepository count: MongoChange) equals: 2.
	mongoChange := (logRepository findAll: MongoChange)
		detect: [ :e | e type = #update asUppercase ].
	self assert: mongoChange mongoCommand notNil.
	self assert: mongoChange type equals: #update asUppercase.
	serializedUpdated := '\{"_c":"DummyPerson","lastName":"Q","_id":ObjectId("{1}"),"modifiedOn":ISODate("{2}"),"firstName":"John","profession":"Carpenter"\}'
		format:
			{(guy id value hex allButFirst: 3) asLowercase.
			guy modifiedOn asString}.
	expectation := 'db.DummyPerson.updateOne(\{"_id": ObjectId("{1}")\},\{$set:{2}\})'
		format:
			{(guy id value hex allButFirst: 3) asLowercase.
			serializedUpdated}.
	self assert: mongoChange mongoCommand equals: expectation
]
