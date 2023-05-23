Class {
	#name : #MaplessBlocklessMongoClientsPool,
	#superclass : #MaplessBlocklessPool,
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #actions }
MaplessBlocklessMongoClientsPool >> closeClient: aClient [
	aClient close
]

{ #category : #accessing }
MaplessBlocklessMongoClientsPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MongoCurrentClient
]

{ #category : #actions }
MaplessBlocklessMongoClientsPool >> isClientConnected: aClient [
	"Answers true if the resource is actually active."

	^ aClient isOpen
]

{ #category : #actions }
MaplessBlocklessMongoClientsPool >> makeClientWith: aMongoUrl [
	"Answers a new open MongoAPI client or nil if there is a network error."

	| newClient isAuthenticated |
	[ newClient := (MongoAPI mongoUrl: aMongoUrl)
		open;
		yourself ]
		on: NetworkError
		do: [ :x | ^ nil ].
	self isUsingAuth
		ifTrue: [ isAuthenticated := self authenticate: newClient.
			isAuthenticated
				ifFalse: [ ^ self error: 'Authentication failed' ] ].
	^ newClient
]
