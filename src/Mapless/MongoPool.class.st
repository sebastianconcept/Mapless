Class {
	#name : #MongoPool,
	#superclass : #MaplessAbstractPool,
	#category : #'Mapless-Mongo'
}

{ #category : #actions }
MongoPool >> authenticate: mongoClient [
	^ mongoClient
		authenticateUsername: self username
		password: self password
		database: self authenticationDatabaseName
]

{ #category : #accessing }
MongoPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."
	^ MongoCurrentClient
]

{ #category : #actions }
MongoPool >> databaseAt: aDatabaseName [ 

	self do:[ :client |
		^ client databaseNamed: aDatabaseName ]
]

{ #category : #actions }
MongoPool >> databaseAt: aDatabaseName do: aBlock [

	self do:[ :client |
		(client databaseNamed: aDatabaseName) do: [ ^ aBlock value ] ]
]

{ #category : #actions }
MongoPool >> ifUnavailablePurge: aMongoClient [
	"Tests aMongoClient and remove it from this pool if invalid."

	(aMongoClient isAvailable not or: [
	([aMongoClient databases first collections.
	true] on: Error do: [ :x | false]) not ] ) ifTrue: [
		self remove:  aMongoClient ]
]

{ #category : #actions }
MongoPool >> initialize [
	super initialize.

	MongoAPI defaultAuthMechanismClass: SCRAMSHA1AuthMechanism.
]

{ #category : #actions }
MongoPool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"

	| newClient isAuthenticated |
	newClient := (MongoAPI
		host: (OSEnvironment current at: 'MONGO_ADDRESS' ifAbsent: [ 'localhost' ])
		port: (OSEnvironment current at: 'MONGO_PORT' ifAbsent: [ 27017 ]) asInteger)
		open;
		yourself.
	self isUsingAuth
		ifTrue: [ isAuthenticated := self authenticate: newClient.
			isAuthenticated
				ifFalse: [ ^ self error: 'Authentication failed' ] ].
	self logNewClient: newClient.
	^ newClient
]

{ #category : #reactions }
MongoPool >> onLogout: aMongo [

	self remove: aMongo 
]

{ #category : #actions }
MongoPool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."
	
	self busyClients copy do:[ :e | self ifUnavailablePurge: e ].
	self idleClients copy do:[ :e | self ifUnavailablePurge: e ]
]
