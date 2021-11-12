"
I will help the replica set pool to get the clients for read-only and read-write.
I can help to gracefully handle a change of primary in the replica set.
"
Class {
	#name : #MaplessMongoResolver,
	#superclass : #Object,
	#instVars : [
		'primaryMongoUrl',
		'mongoUrls',
		'secondaryMongoUrls'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessMongoResolver class >> fromMongoUrls: someMongoUrls [
	^ self new
		initializeOn: someMongoUrls;
		yourself
]

{ #category : #actions }
MaplessMongoResolver >> findPrimaryFor: aMaplessMongoReplicaSetPool [
	"Answers true if the primary was found.
	It will create one client to every address configured for the pool and close it after
	testing if it's the address of the primary."

	| client |
	self mongoUrls
		do: [ :mongoUrl | 
			[ client := aMaplessMongoReplicaSetPool makeClientWith: mongoUrl.
			(client notNil and: [ client getIsPrimary ])
				ifTrue: [ self primaryMongoUrl: mongoUrl.
					aMaplessMongoReplicaSetPool
						triggerEvent: #primaryFound
						with: mongoUrl ] ]
				ensure: [ client ifNotNil: [ client close ] ] ].
	^ primaryMongoUrl notNil
]

{ #category : #accessing }
MaplessMongoResolver >> getPrimaryMongoUrl [
	^ primaryMongoUrl
]

{ #category : #accessing }
MaplessMongoResolver >> getSecondaryMongoUrl [
	self secondaryMongoUrls atEnd
		ifTrue: [ self secondaryMongoUrls reset ].
	^ self secondaryMongoUrls next
]

{ #category : #testing }
MaplessMongoResolver >> hasPrimary [
	^ primaryMongoUrl notNil
]

{ #category : #initializing }
MaplessMongoResolver >> initializeOn: someMongoUrls [
	mongoUrls := someMongoUrls
]

{ #category : #initializing }
MaplessMongoResolver >> initializeSecondaryMongoUrls [
	^ secondaryMongoUrls := (mongoUrls
		reject: [ :each | each = primaryMongoUrl ]) readStream
]

{ #category : #accessing }
MaplessMongoResolver >> mongoUrls [
	^ mongoUrls
]

{ #category : #accessing }
MaplessMongoResolver >> primaryMongoUrl [
	^ primaryMongoUrl
]

{ #category : #actions }
MaplessMongoResolver >> primaryMongoUrl: aMongoUrl [
	primaryMongoUrl := aMongoUrl.
	self initializeSecondaryMongoUrls
]

{ #category : #actions }
MaplessMongoResolver >> resetRoles [
	primaryMongoUrl := nil.
	secondaryMongoUrls := nil
]

{ #category : #accessing }
MaplessMongoResolver >> secondaryMongoUrls [
	^ secondaryMongoUrls ifNil: [ self initializeSecondaryMongoUrls ]
]

{ #category : #actions }
MaplessMongoResolver >> setPrimary: aMongoUrl [
	primaryMongoUrl := aMongoUrl
]
