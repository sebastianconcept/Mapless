Class {
	#name : #MaplessBlocklessMongoReadWritePool,
	#superclass : #MaplessBlocklessMongoClientsPool,
	#instVars : [
		'primaryUrl'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #actions }
MaplessBlocklessMongoReadWritePool >> makeClient [
	^ self makeClientWith: primaryUrl
]

{ #category : #reactions }
MaplessBlocklessMongoReadWritePool >> onPrimaryChanged: aMongoUrl [
	(primaryUrl notNil
		and: [ primaryUrl port = aMongoUrl port
				and: [ primaryUrl host = aMongoUrl host ] ])
		ifFalse: [ primaryUrl := aMongoUrl.
			self resetClients ].
	self ensureClients
]
