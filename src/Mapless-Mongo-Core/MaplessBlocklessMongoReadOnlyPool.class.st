Class {
	#name : #MaplessBlocklessMongoReadOnlyPool,
	#superclass : #MaplessBlocklessMongoClientsPool,
	#instVars : [
		'secondaryUrls'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #actions }
MaplessBlocklessMongoReadOnlyPool >> ensureSecondaries [

	self resetClients.
	self ensureClients
]

{ #category : #actions }
MaplessBlocklessMongoReadOnlyPool >> makeClient [
	^ self makeClientWith: self nextSecondaryUrl
]

{ #category : #actions }
MaplessBlocklessMongoReadOnlyPool >> nextSecondaryUrl [
	secondaryUrls atEnd
		ifTrue: [ secondaryUrls reset ].
	^ secondaryUrls next
]

{ #category : #reactions }
MaplessBlocklessMongoReadOnlyPool >> onSecondariesChanged: someMongoUrls [
	secondaryUrls := someMongoUrls readStream.
	self ensureSecondaries
]
