"
I'm an abstract class in the hierarchy that helps to select which MongoDB client to pick from the pool of connections in a MongoDB Replica Set.

- In mongoUrls I have the URLs of the memebrs of the replica set.

- In lastConnectionIndex I remember the index of the last mongoUrl used in mongoUrls for making a new client.
"
Class {
	#name : #MaplessMongoReplicaSetClientSelectionPolicy,
	#superclass : #Object,
	#instVars : [
		'mongoUrls',
		'lastConnectionIndex'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessMongoReplicaSetClientSelectionPolicy class >> on: someMongoUrls [
	^ self new
		mongoUrls: someMongoUrls;
		yourself
]

{ #category : #initializing }
MaplessMongoReplicaSetClientSelectionPolicy >> initializeLastConnectionIndex [
	^ lastConnectionIndex := 1
]

{ #category : #accessing }
MaplessMongoReplicaSetClientSelectionPolicy >> lastConnectionIndex [
	^ lastConnectionIndex ifNil: [ self initializeLastConnectionIndex ]
]

{ #category : #accessing }
MaplessMongoReplicaSetClientSelectionPolicy >> mongoUrls [
	^ mongoUrls
]

{ #category : #accessing }
MaplessMongoReplicaSetClientSelectionPolicy >> mongoUrls: anObject [
	mongoUrls := anObject
]

{ #category : #accessing }
MaplessMongoReplicaSetClientSelectionPolicy >> nextConnectionIndex [
	"Ansewers the increased last connection index starting over once it's at the last one."

	^ lastConnectionIndex = mongoUrls size
		ifTrue: [ lastConnectionIndex := 1 ]
		ifFalse: [ lastConnectionIndex := self lastConnectionIndex + 1 ]
]

{ #category : #accessing }
MaplessMongoReplicaSetClientSelectionPolicy >> nextMongoUrl [
	^ self mongoUrls at: self nextConnectionIndex
]
