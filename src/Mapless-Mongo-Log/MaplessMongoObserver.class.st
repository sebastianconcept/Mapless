"
I can observe a MaplessMongoRepository (standalone or replica set based) for its delete, insert and update commands and produce a log with the commands that would allow to audit or even reproduce these changes elsewere.
"
Class {
	#name : #MaplessMongoObserver,
	#superclass : #Object,
	#instVars : [
		'logRepository',
		'unobservable'
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

{ #category : #accessing }
MaplessMongoObserver class >> unobservableMaplessClasses [
	^ {MongoChange.
	MongoChangeSequence}
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

{ #category : #testing }
MaplessMongoObserver >> hasMongoChangeSequence [
	^ (logRepository count: MongoChangeSequence) > 0
]

{ #category : #querying }
MaplessMongoObserver >> incrementedSequenceNumber [
	"Answers the last sequence number incremented by 1.
	The last sequence number is expected to be maintained 
	in the MongoChangeSequence collection that holds 
	one single document with the `last` property integer value."

	^ logRepository
		readWriteDo: [ logRepository database
				command:
					{('findAndModify' -> MongoChangeSequence collectionName).
					('query'
						-> {('_id' -> {('$ne' -> nil)} asDictionary)} asDictionary).
					('update'
						-> {('$inc' -> {('last' -> 1)} asDictionary)} asDictionary)}
						asOrderedDictionary ]
]

{ #category : #initialization }
MaplessMongoObserver >> initializeOn: aMaplessMongoRepository loggingIn: aMaplessRepository [
	logRepository := aMaplessRepository.
	self observe: aMaplessMongoRepository.
	self hasMongoChangeSequence
		ifFalse: [ logRepository
				save:
					(MongoChangeSequence new
						last: 1;
						yourself) ]
]

{ #category : #initialization }
MaplessMongoObserver >> initializeUnobservable [
	^ unobservable := self class unobservableMaplessClasses
]

{ #category : #reactions }
MaplessMongoObserver >> mongoDeleteOf: aMapless serializable: aSerializable writeConcern: aWriteConcern in: aMaplessMongoRepository [
	| mongoChange mongoDeleteOneCommand jsonishString |
	(self unobservable includes: aMapless maplessClass)
		ifTrue: [ ^ self ].
	jsonishString := self asJSONishString: aSerializable.
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
		collectionName: aMapless class collectionName;
		sequenceNumber: self nextSequenceNumber;
		type: #delete asUppercase;
		mongoCommand: mongoDeleteOneCommand;
		document: aSerializable;		
		yourself.
	logRepository save: mongoChange
]

{ #category : #reactions }
MaplessMongoObserver >> mongoInsertOf: aMapless serializable: aSerializable writeConcern: aWriteConcern in: aMaplessMongoRepository [
	| mongoInsertOneCommand mongoChange jsonishString |
	(self unobservable includes: aMapless maplessClass)
		ifTrue: [ ^ self ].
	jsonishString := self asJSONishString: aSerializable.
	mongoInsertOneCommand := String
		streamContents: [ :stream | 
			stream
				<<
					('db.{1}.insertOne({2})'
						format:
							{(aMaplessMongoRepository
								databaseCollectionNamed: aMapless class collectionName).
							jsonishString}) ].
	mongoChange := MongoChange new
		collectionName: aMapless class collectionName;
		sequenceNumber: self nextSequenceNumber;
		type: #insert asUppercase;
		mongoCommand: mongoInsertOneCommand;
		document: aSerializable;
		yourself.
	logRepository save: mongoChange
]

{ #category : #reactions }
MaplessMongoObserver >> mongoUpdateOf: aMapless serializable: aSerializable writeConcern: aWriteConcern in: aMaplessMongoRepository [
	| mongoUpdateOneCommand mongoChange jsonishString |
	(self unobservable includes: aMapless maplessClass)
		ifTrue: [ ^ self ].
	jsonishString := self asJSONishString: aSerializable.
	mongoUpdateOneCommand := String
		streamContents: [ :stream | 
			stream
				<<
					('db.{1}.updateOne(\{"_id": ObjectId("{2}")\},\{$set:{3}\})'
						format:
							{(aMaplessMongoRepository
								databaseCollectionNamed: aMapless class collectionName).
							(aMapless id value hex allButFirst: 3) asLowercase.
							jsonishString}) ].
	mongoChange := MongoChange new
		collectionName: aMapless class collectionName;
		sequenceNumber: self nextSequenceNumber;
		type: #update asUppercase;
		mongoCommand: mongoUpdateOneCommand;
		document: aSerializable;
		yourself.
	logRepository save: mongoChange
]

{ #category : #querying }
MaplessMongoObserver >> nextSequenceNumber [
	^ (self incrementedSequenceNumber at: 'value')
		ifNotNil: [ :value | value at: 'last' ]
		ifNil: [ MaplessMongoError
				signal: 'Sequence number was not properly initialized' ]
]

{ #category : #initialization }
MaplessMongoObserver >> observe: aMaplessMongoRepository [
	aMaplessMongoRepository
		when: #maplessMongoInsertOf:serializable:writeConcern:in:
			send: #mongoInsertOf:serializable:writeConcern:in:
			to: self;
		when: #maplessMongoDeleteOf:serializable:writeConcern:in:
			send: #mongoDeleteOf:serializable:writeConcern:in:
			to: self;
		when: #maplessMongoUpdateOf:serializable:writeConcern:in:
			send: #mongoUpdateOf:serializable:writeConcern:in:
			to: self;
		yourself
]

{ #category : #accessing }
MaplessMongoObserver >> unobservable [
	"Answer the Mapless classes of objects which changes will be unobservable."

	^ unobservable ifNil: [ self initializeUnobservable ]
]
