Class {
	#name : #MaplessBlocklessMongoReplicaSetPool,
	#superclass : #MaplessAbstracMongoPool,
	#instVars : [
		'readOnly',
		'readWrite',
		'resolver'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessBlocklessMongoReplicaSetPool class >> fromString: aStringOfOptionalWeigthsAndMongoUrls database: databaseName [
	| parts weights mongoUrls url weight |
	weights := Dictionary new.
	parts := aStringOfOptionalWeigthsAndMongoUrls substrings: ','.
	parts := parts collect: [ :each | each substrings: '@' ].
	parts
		do: [ :each | 
			each size > 1
				ifTrue: [ url := each second.
					weight := each first asNumber ]
				ifFalse: [ url := each first.
					weight := 1 ].
			weights at: url asMongoUrl put: weight ].
	mongoUrls := weights keys.
	^ self mongoUrls: mongoUrls weights: weights database: databaseName
]

{ #category : #'instance creation' }
MaplessBlocklessMongoReplicaSetPool class >> mongoUrls: someMongoUrls database: databaseName [
	^ self
		mongoUrls: someMongoUrls asOrderedCollection
		database: databaseName
		username: ''
		password: ''
]

{ #category : #'instance creation' }
MaplessBlocklessMongoReplicaSetPool class >> mongoUrls: someMongoUrls database: databaseName username: aUserName password: aPassword [
	^ self basicNew
		initializeMongoUrls: (someMongoUrls collect: #asMongoUrl)
			database: databaseName
			username: aUserName
			password: aPassword;
		yourself
]

{ #category : #'instance creation' }
MaplessBlocklessMongoReplicaSetPool class >> mongoUrls: someMongoUrls weights: weightsDictionary database: databaseName [
	^ self
		mongoUrls: someMongoUrls
		weights: weightsDictionary
		database: databaseName
		username: ''
		password: ''
]

{ #category : #'instance creation' }
MaplessBlocklessMongoReplicaSetPool class >> mongoUrls: someMongoUrls weights: weightsDictionary database: databaseName username: aUserName password: aPassword [
	^ self basicNew
		initializeMongoUrls: (someMongoUrls collect: #asMongoUrl)
			weights: weightsDictionary
			database: databaseName
			username: aUserName
			password: aPassword;
		yourself
]

{ #category : #tests }
MaplessBlocklessMongoReplicaSetPool class >> test [
	"Answers a new pool handly for testing"

	^ self
		mongoUrls: {'mongo1:27017' . 'mongo2:27018' . 'mongo3:27019'}
		database: 'Mapless-Test'
]

{ #category : #actions }
MaplessBlocklessMongoReplicaSetPool >> findPrimary [
	"Find the primary of the replica set"

	^ resolver findPrimaryFor: self
]

{ #category : #testing }
MaplessBlocklessMongoReplicaSetPool >> hasPrimary [
	^ resolver hasPrimary
]

{ #category : #initialization }
MaplessBlocklessMongoReplicaSetPool >> initialize [
	super initialize.
	readOnly := MaplessBlocklessMongoReadOnlyPool new.
	readWrite := MaplessBlocklessMongoReadWritePool new.
]

{ #category : #initialization }
MaplessBlocklessMongoReplicaSetPool >> initializeMongoUrls: someMongoUrls database: databaseName username: aUserName password: aPassword [
	self initialize.
	username := aUserName.
	password := aPassword.
	resolver := MaplessMongoReplicaSetResolver
		fromMongoUrls: someMongoUrls
]

{ #category : #initialization }
MaplessBlocklessMongoReplicaSetPool >> initializeMongoUrls: someMongoUrls weights: weightsDictionary database: databaseName username: aUserName password: aPassword [
	self initialize.
	username := aUserName.
	password := aPassword.
	resolver := MaplessMongoReplicaSetResolver fromMongoUrls: someMongoUrls.

]

{ #category : #accessing }
MaplessBlocklessMongoReplicaSetPool >> maxReadOnlyClients: anInteger [
	readOnly maximum: anInteger
]

{ #category : #accessing }
MaplessBlocklessMongoReplicaSetPool >> maxReadWriteClients: anInteger [
	readWrite maximum: anInteger
]

{ #category : #accessing }
MaplessBlocklessMongoReplicaSetPool >> minReadOnlyClients: anInteger [
	readOnly minimum: anInteger
]

{ #category : #accessing }
MaplessBlocklessMongoReplicaSetPool >> minReadWriteClients: anInteger [
	readWrite minimum: anInteger
]

{ #category : #reactions }
MaplessBlocklessMongoReplicaSetPool >> onPrimaryFound [
	readWrite onPrimaryChanged: resolver primaryUrl.
	readOnly onSecondariesChanged: resolver secondaryUrls
]

{ #category : #actions }
MaplessBlocklessMongoReplicaSetPool >> readOnlyDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle read-only clients as parameter."

	^ readOnly withClientDo: aBlock
]

{ #category : #actions }
MaplessBlocklessMongoReplicaSetPool >> readWriteDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle read-wtrite clients as parameter."

	^ readWrite withClientDo: aBlock
]

{ #category : #accessing }
MaplessBlocklessMongoReplicaSetPool >> resolver [
	^ resolver
]

{ #category : #actions }
MaplessBlocklessMongoReplicaSetPool >> start [
	self findPrimary
]

{ #category : #actions }
MaplessBlocklessMongoReplicaSetPool >> stop [
	readOnly ifNotNil: [ readOnly stop ].
	readWrite ifNotNil: [ readWrite stop ]
]
