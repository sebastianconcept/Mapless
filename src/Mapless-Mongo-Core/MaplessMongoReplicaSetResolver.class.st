"
I will help the replica set pool to get the clients for read-only and read-write.
I can help to gracefully handle a change of primary in the replica set.
"
Class {
	#name : #MaplessMongoReplicaSetResolver,
	#superclass : #Object,
	#instVars : [
		'mongoUrls',
		'primaryUrl',
		'secondaryUrls'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessMongoReplicaSetResolver class >> fromMongoUrls: someMongoUrls [
	^ self new
		initializeOn: someMongoUrls;
		yourself
]

{ #category : #actions }
MaplessMongoReplicaSetResolver >> findPrimaryFor: aMaplessMongoReplicaSetPool [
	"Answers true if the primary was found."

	| client rsStatus |
	self mongoUrls
		do: [ :mongoUrl | 
			[ client := aMaplessMongoReplicaSetPool makeClientWith: mongoUrl.
			client notNil
				ifTrue: [ rsStatus := client replicaSetStatus.
					(rsStatus members anySatisfy: [ :e | e isPrimary ])
						ifFalse: [ ReplicaSetPrimaryNotFound
								signal: 'Primary node could not be reached.' ].
					self updateStatusFromStatus: rsStatus.
					aMaplessMongoReplicaSetPool onPrimaryFound: client ] ]
				ensure: [ client ifNotNil: [ client close ] ] ].
	primaryUrl
		ifNil: [ ReplicaSetPrimaryNotFound
				signal: 'Primary node could not be reached.' ]
]

{ #category : #testing }
MaplessMongoReplicaSetResolver >> hasPrimary [
	^ primaryUrl notNil
]

{ #category : #initialization }
MaplessMongoReplicaSetResolver >> initializeOn: someMongoUrls [
	mongoUrls := someMongoUrls
]

{ #category : #accessing }
MaplessMongoReplicaSetResolver >> mongoUrls [
	^ mongoUrls
]

{ #category : #accessing }
MaplessMongoReplicaSetResolver >> primaryUrl [
	^ primaryUrl
]

{ #category : #actions }
MaplessMongoReplicaSetResolver >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			('(p: {1} s: {2})'
				format:
					{primaryUrl asString.
					secondaryUrls printString})
]

{ #category : #actions }
MaplessMongoReplicaSetResolver >> resetRoles [
	primaryUrl := nil.
	secondaryUrls := nil
]

{ #category : #accessing }
MaplessMongoReplicaSetResolver >> secondaryUrls [
	^ secondaryUrls
]

{ #category : #actions }
MaplessMongoReplicaSetResolver >> updateStatusFrom: aMongoAPI [
	"Make this resolver aware of the latest status of the replica set according to
	the informed status of the replica set as reported from aMongoAPI."

	self updateStatusFromStatus: aMongoAPI replicaSetStatus
]

{ #category : #actions }
MaplessMongoReplicaSetResolver >> updateStatusFromStatus: aMongoReplicaSetStatus [
	"Make this resolver aware of the latest status of 
	the replica set according to aMongoReplicaSetStatus."

	primaryUrl := (aMongoReplicaSetStatus members
		detect: [ :each | each isPrimary ]
		ifNone: [ ReplicaSetPrimaryNotFound signal: 'Primary node unavailable?' ]) name asMongoUrl.
	secondaryUrls := aMongoReplicaSetStatus secondaryMembers
		collect: [ :e | e name asMongoUrl ].
		
	self triggerEvent: #rolesUpdated
]
