"
I can observe a MaplessMongoRepository (standalone or replica set based) for its delete, insert and update commands and produce a log with the commands that would allow to audit or even reproduce these changes elsewere.
"
Class {
	#name : #MaplessMongoObserver,
	#superclass : #Object,
	#instVars : [
		'logRepository'
	],
	#category : #'Mapless-Mongo-Log-Core'
}

{ #category : #'instance creation' }
MaplessMongoObserver class >> on: aMaplessMongoRepository [
	^ self on: aMaplessMongoRepository loggingIn: aMaplessMongoRepository
]

{ #category : #'instance creation' }
MaplessMongoObserver class >> on: aMaplessMongoRepository loggingIn: aMaplessRepository [
	^ self new
		initializeOn: aMaplessMongoRepository loggingIn: aMaplessRepository;
		yourself
]

{ #category : #converting }
MaplessMongoObserver >> asJSONishString: aSerializable [
	"Answers the JSON-like representation that is accepted by MongoDB"

	^ String
		streamContents: [ :stream | 
			(NeoJSONWriter on: stream)
				prettyPrint: false;
				nextPut: aSerializable ]
]

{ #category : #initialization }
MaplessMongoObserver >> initializeOn: aMaplessMongoRepository loggingIn: aMaplessRepository [
	logRepository := aMaplessRepository.
	self observe: aMaplessMongoRepository
]

{ #category : #reactions }
MaplessMongoObserver >> mongoDeleteOf: aMapless writeConcern: aWriteConcern in: aMaplessMongoRepository [
	| mongoChange mongoDeleteOneCommand |
	mongoDeleteOneCommand := String
		streamContents: [ :stream | 
			stream
				<<
					('db.{1}.deleteOne(\{"_id": ObjectId("{2}")\})'
						format:
							{(aMaplessMongoRepository
								databaseCollectionNamed: aMapless class collectionName) name.
							(aMapless id value hex allButFirst: 3) asLowercase}) ].
	mongoChange := MongoChange new
		type: #delete;
		mongoCommand: mongoDeleteOneCommand;
		yourself.
	logRepository save: mongoChange
]

{ #category : #reactions }
MaplessMongoObserver >> mongoInsertOf: aMapless serializable: aSerializable writeConcern: aWriteConcern in: aMaplessMongoRepository [
	| mongoInsertOneCommand mongoChange jsonish |
	jsonish := self asJSONishString: aSerializable.
	mongoInsertOneCommand := String
		streamContents: [ :stream | 
			stream
				<<
					('db.{1}.insertOne({2})'
						format:
							{(aMaplessMongoRepository
								databaseCollectionNamed: aMapless class collectionName).
							jsonish}) ].
	mongoChange := MongoChange new
		type: #insert;
		mongoCommand: mongoInsertOneCommand;
		jsonish: jsonish;
		yourself.
	logRepository save: mongoChange
]

{ #category : #initialization }
MaplessMongoObserver >> observe: aMaplessMongoRepository [
	aMaplessMongoRepository
		when: #maplessMongoInsertOf:serializable:writeConcern:in:
			send: #mongoInsertOf:serializable:writeConcern:in:
			to: self;
		when: #maplessMongoDeleteOf:writeConcern:in:
			send: #mongoDeleteOf:writeConcern:in:
			to: self;
		yourself
]
