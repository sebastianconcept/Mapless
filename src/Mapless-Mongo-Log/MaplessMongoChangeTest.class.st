"
Coverage for MongoChages features
"
Class {
	#name : #MaplessMongoChangeTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository',
		'logRepository'
	],
	#category : #'Mapless-Mongo-Log-Tests'
}

{ #category : #history }
MaplessMongoChangeTest class >> maplessClasses [
	^ {DummyPerson.
	DummyUser.
	DummyTag}
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

	self class maplessClasses do: [ :each | repository destroyAll: each ]
]

{ #category : #running }
MaplessMongoChangeTest >> setUp [
	super setUp.
	repository := self newRepository.
	self resetDatabase.
	logRepository := MaplessMemoryRepository
		for: 'Mapless-Test-Log'
		with: MaplessMemoryAccessor new
]

{ #category : #running }
MaplessMongoChangeTest >> testSimpleDeleteLog [
	| guy observer mongoChange expectation |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	observer := MaplessMongoObserver
		on: repository
		loggingIn: logRepository.
	repository save: guy.
	self assert: (repository count: DummyPerson) equals: 1.
	self assert: (logRepository count: MongoChange) equals: 1.
	self assert: (repository existsId: guy id of: DummyPerson).
	repository destroy: guy.
	self assert: (repository count: DummyPerson) equals: 0.
	self deny: (repository existsId: guy id of: DummyPerson).
	self assert: (logRepository count: MongoChange) equals: 2.
	mongoChange := (logRepository findAll: MongoChange)
		detect: [ :e | e type = #delete ].
	expectation := 'db.DummyPerson.deleteOne(\{"_id": ObjectId("{1}")\})'
		format: {(guy id value hex allButFirst: 3) asLowercase}.
	self assert: mongoChange mongoCommand notNil.
	self assert: mongoChange type equals: #delete.
	self assert: mongoChange mongoCommand equals: expectation
]

{ #category : #running }
MaplessMongoChangeTest >> testSimpleInsertLog [
	| guy observer mongoChange expectation |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	observer := MaplessMongoObserver
		on: repository
		loggingIn: logRepository.
	repository save: guy.
	self assert: (logRepository count: MongoChange) equals: 1.
	mongoChange := (logRepository findAll: MongoChange) first.
	expectation := 'db.DummyPerson.insertOne(\{"_c":"DummyPerson","lastName":"q","_id":ObjectId("{1}"),"modifiedOn":ISODate("{2}"),"firstName":"john"\})'
		format:
			{(guy id value hex allButFirst: 3) asLowercase.
			guy modifiedOn asString}.
	self assert: mongoChange mongoCommand notNil.
	self assert: mongoChange type equals: #insert.
	self assert: mongoChange jsonish notNil.
	self assert: mongoChange mongoCommand equals: expectation
]

{ #category : #running }
MaplessMongoChangeTest >> testSimpleUpdateLog [
	| guy observer |
	guy := DummyPerson new
		firstName: 'john';
		lastName: 'q';
		yourself.
	repository save: guy
]
