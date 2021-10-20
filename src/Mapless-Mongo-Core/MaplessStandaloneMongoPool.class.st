"
Mapless uses this class to have pools of MongoDB clients available for the repository to use.
If more clients are needed, it will create them lazily up to a max.
When the max is reached, it will start throwing exceptions if the load wants to create more.
"
Class {
	#name : #MaplessStandaloneMongoPool,
	#superclass : #MaplessAbstractPool,
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #actions }
MaplessStandaloneMongoPool >> authenticate: mongoClient [
	^ mongoClient
		authenticateUsername: self username
		password: self password
		database: self authenticationDatabaseName
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MongoCurrentClient
]

{ #category : #actions }
MaplessStandaloneMongoPool >> ifUnavailablePurge: aMongoClient [
	"Tests aMongoClient and remove it from this pool if invalid."

	(aMongoClient isAvailable not
		or: [ ([ aMongoClient databases first collections.
			true ]
				on: Error
				do: [ :x | false ]) not ])
		ifTrue: [ self remove: aMongoClient ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> initialize [
	super initialize.
	MongoAPI defaultAuthMechanismClass: SCRAMSHA1AuthMechanism
]

{ #category : #actions }
MaplessStandaloneMongoPool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"

	| newClient isAuthenticated |
	newClient := (MongoAPI host: hostname port: port asInteger)
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
MaplessStandaloneMongoPool >> onLogout: aMongo [
	self remove: aMongo
]

{ #category : #actions }
MaplessStandaloneMongoPool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."

	self busyClients copy do: [ :e | self ifUnavailablePurge: e ].
	self idleClients copy do: [ :e | self ifUnavailablePurge: e ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> readOnlyDo: aBlock [
	^ self do: aBlock
]

{ #category : #actions }
MaplessStandaloneMongoPool >> readWriteDo: aBlock [
	^ self do: aBlock
]
