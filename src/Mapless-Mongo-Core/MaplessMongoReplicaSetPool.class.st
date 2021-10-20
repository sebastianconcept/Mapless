Class {
	#name : #MaplessMongoReplicaSetPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'mongoUrls',
		'selectionPolicy'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> mongoUrls: someMongoUrls database: databaseName [
	^ self
		mongoUrls: someMongoUrls asOrderedCollection
		database: databaseName
		username: ''
		password: ''
]

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> mongoUrls: someMongoUrls database: databaseName username: aUserName password: aPassword [
	^ self basicNew
		initializeMongoUrls: (someMongoUrls collect: #asMongoUrl)
			database: databaseName
			username: aUserName
			password: aPassword;
		yourself
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MongoCurrentClient
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> do: aBlock [
	"In replica sets, use the explicit versions readOnlyDo: or readWriteDo:"

	self shouldNotImplement
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeMongoUrls: someMongoUrls database: databaseName username: aUserName password: aPassword [
	self initialize.
	username := aUserName.
	password := aPassword.
	mongoUrls := someMongoUrls
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeSelectionPolicy [
	^ selectionPolicy := MaplessMongoReplicaSetReadOnlyOnSecondaries
		on: mongoUrls
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readOnlyDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle read-only clients as parameter."

	| client |
	client := self selectionPolicy requestReadOnlyClientFrom: self.
	^ self currentClientDynamicVariable
		value: client
		during: [ [ [ aBlock value: client ]
				on: Error
				do: [ :x | 
					client reset.
					x pass ] ]
				ensure: [ self returnClient: client ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readWriteDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle read-write clients as parameter."

	| client |
	client := self selectionPolicy requestReadWriteClientFrom: self.
	^ self currentClientDynamicVariable
		value: client
		during: [ [ [ aBlock value: client ]
				on: Error
				do: [ :x | 
					client reset.
					x pass ] ]
				ensure: [ self returnClient: client ] ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> selectionPolicy [
	^ selectionPolicy ifNil: [ self initializeSelectionPolicy ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> selectionPolicy: anObject [
	selectionPolicy := anObject
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> start: anInteger [
	anInteger
		timesRepeat: [ self idleClients add: (self selectionPolicy makeClientFor: self) ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> withClientDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client as aBlock argument."

	"Use the explicit read-only or read-write methods"

	self shouldNotImplement
]
