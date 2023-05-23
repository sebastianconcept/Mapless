Class {
	#name : #MaplessAbstracMongoPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'authenticationDatabaseName'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessAbstracMongoPool class >> local [
	^ self
		hostname: 'localhost'
		port: 27017
		username: nil
		password: nil
]

{ #category : #actions }
MaplessAbstracMongoPool >> authenticate: aMongoClient [
	^ aMongoClient
		authenticateUsername: self username
		password: self password
		database: self authenticationDatabaseName
]

{ #category : #accessing }
MaplessAbstracMongoPool >> authenticationDatabaseName [
	^ authenticationDatabaseName
		ifNil: [ self initializeAuthenticationDatabaseName ]
]

{ #category : #accessing }
MaplessAbstracMongoPool >> authenticationDatabaseName: aString [
	authenticationDatabaseName := aString
]

{ #category : #accessing }
MaplessAbstracMongoPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MongoCurrentClient
]

{ #category : #testing }
MaplessAbstracMongoPool >> hasHealthChecker [
	^ false
]

{ #category : #initialization }
MaplessAbstracMongoPool >> initializeAuthenticationDatabaseName [
	^ authenticationDatabaseName := 'admin'
]

{ #category : #actions }
MaplessAbstracMongoPool >> makeClientWith: aMongoUrl [
	"Answers a new open MongoAPI client or nil if there is a network error."

	| newClient isAuthenticated |
	self triggerEvent: #creatingClientTo: with: aMongoUrl.
	[ newClient := (MongoAPI mongoUrl: aMongoUrl)
		when: #closingConnection: send: #onClientClosed: to: self;
		open;
		yourself ]
		on: NetworkError
		do: [ :x | 
			self
				triggerEvent: #clientCreationTo:failed:
				withArguments:
					{aMongoUrl.
					x}.
			^ nil ].
	self isUsingAuth
		ifTrue: [ isAuthenticated := self authenticate: newClient.
			isAuthenticated
				ifFalse: [ ^ self error: 'Authentication failed' ] ].
	^ newClient
]

{ #category : #reactions }
MaplessAbstracMongoPool >> onClientClosed: aMongoAPI [
	self triggerEvent: #clientClosed: with: aMongoAPI
]

{ #category : #actions }
MaplessAbstracMongoPool >> returningUnusedClient [
	Transcript
		cr;
		show: 'Warning: returning a client that is not in among the busy ones'
]
