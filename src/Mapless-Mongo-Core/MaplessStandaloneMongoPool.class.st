"
Mapless uses this class to have pools of MongoDB clients available for the repository to use.
If more clients are needed, it will create them lazily up to a max.
When the max is reached, it will start throwing exceptions if the load wants to create more.
"
Class {
	#name : #MaplessStandaloneMongoPool,
	#superclass : #MaplessAbstracMongoPool,
	#instVars : [
		'minClients',
		'maxClients',
		'clientsMutex',
		'clientsMonitor',
		'busyClients',
		'idleClients'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'instance creation' }
MaplessStandaloneMongoPool class >> defaultMaxClients [
	"Default maximum quantity of clients for the connection pool used in case no max was specified"

	^ 500
]

{ #category : #'instance creation' }
MaplessStandaloneMongoPool class >> defaultMinClients [
	"Default minimmum quantity of clients for the connection pool used in case no max was specified"

	^ 2
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> allClients [
	^ self busyClients , self idleClients
]

{ #category : #actions }
MaplessStandaloneMongoPool >> authenticate: aMongoClient [
	^ aMongoClient
		authenticateUsername: self username
		password: self password
		database: self authenticationDatabaseName
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> busyClients [
	"Answers the bunch of clients that are currently busy"

	^ busyClients ifNil: [ self initializeBusyClients ]
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> clientsMonitor [
	"Answers the monitor used to protect clients usage"

	^ clientsMonitor ifNil: [ self initializeClientsMonitor ]
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> clientsMutex [
	"Answers the mutex used to protect clients usage"

	^ clientsMutex ifNil: [ self initializeClientsMutex ]
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MongoCurrentClient
]

{ #category : #actions }
MaplessStandaloneMongoPool >> do: aBlock [
	"Evaluates aBlock using a client"

	^ self withClientDo: aBlock
]

{ #category : #testing }
MaplessStandaloneMongoPool >> hasBusyClients [
	"Answers true if this pool has, at least one, busy client"

	^ self busyClients notEmpty
]

{ #category : #testing }
MaplessStandaloneMongoPool >> hasClients [
	"Answers true if this pool has at least one client"

	^ self hasIdleClients or: [ self hasBusyClients ]
]

{ #category : #testing }
MaplessStandaloneMongoPool >> hasIdleClients [
	"Answers true if this pool has, at least one, idle client"

	^ self idleClients notEmpty
]

{ #category : #testing }
MaplessStandaloneMongoPool >> hasMaxClients [
	^ self maxClients = self quantityOfClients
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> idleClients [
	"Answers the bunch of clients that are currently idle"

	^ idleClients ifNil: [ self initializeIdleClients ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> ifUnavailablePurge: aMongoClient [
	"Tests aMongoClient and remove it from this pool if invalid."

	(aMongoClient isValid not
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

{ #category : #initialization }
MaplessStandaloneMongoPool >> initializeBusyClients [
	^ busyClients := IdentitySet new
]

{ #category : #initialization }
MaplessStandaloneMongoPool >> initializeClientsMonitor [
	^ clientsMonitor := Monitor new
]

{ #category : #initialization }
MaplessStandaloneMongoPool >> initializeClientsMutex [
	^ clientsMutex := Mutex new
]

{ #category : #initialization }
MaplessStandaloneMongoPool >> initializeIdleClients [
	^ idleClients := IdentitySet new
]

{ #category : #initialization }
MaplessStandaloneMongoPool >> initializeMaxClients [
	^ maxClients := self class defaultMaxClients
]

{ #category : #initialization }
MaplessStandaloneMongoPool >> initializeMinClients [
	^ minClients := self class defaultMinClients
]

{ #category : #actions }
MaplessStandaloneMongoPool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"

	| newMongoClient isAuthenticated |
	newMongoClient := (MongoAPI host: hostname port: port asInteger)
		open;
		yourself.
	self isUsingAuth
		ifTrue: [ isAuthenticated := self authenticate: newMongoClient.
			isAuthenticated
				ifFalse: [ ^ self error: 'Authentication failed' ] ].
	^ newMongoClient
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> maxClients [
	^ maxClients ifNil: [ self initializeMaxClients ]
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> maxClients: anInteger [
	maxClients := anInteger
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> minClients [
	^ minClients  ifNil: [ self initializeMinClients ]
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> minClients: anObject [
	minClients := anObject
]

{ #category : #reactions }
MaplessStandaloneMongoPool >> onLogout: aMongoClient [
	self remove: aMongoClient
]

{ #category : #actions }
MaplessStandaloneMongoPool >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			'(' , self busyClients size asString , ' busy, '
				, self idleClients size asString , ' idle)'
]

{ #category : #actions }
MaplessStandaloneMongoPool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."

	self busyClients copy do: [ :e | self ifUnavailablePurge: e ].
	self idleClients copy do: [ :e | self ifUnavailablePurge: e ]
]

{ #category : #accessing }
MaplessStandaloneMongoPool >> quantityOfClients [
	^ self busyClients size + self idleClients size
]

{ #category : #actions }
MaplessStandaloneMongoPool >> readOnlyDo: aBlock [
	^ self do: aBlock
]

{ #category : #actions }
MaplessStandaloneMongoPool >> readWriteDo: aBlock [
	^ self do: aBlock
]

{ #category : #actions }
MaplessStandaloneMongoPool >> remove: aMongoClient [
	self idleClients remove: aMongoClient ifAbsent: [ nil ].
	self busyClients remove: aMongoClient ifAbsent: [ nil ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> requestClient [
	"Answers a aClient instance taken from the idle clients.
	It'll create a new one if needed.
	It's a thread safe operation."

	^ self clientsMonitor
		critical: [ | mongoClient |
			mongoClient := self hasIdleClients
				ifTrue: [ self idleClients anyOne ]
				ifFalse: [ self hasMaxClients
						ifTrue: [ ^ MaplessMaximumPoolClientsReached signal ].
					self makeClient ].
			(mongoClient notNil and: [ mongoClient isValid not ])
				ifTrue: [ self remove: mongoClient.
					mongoClient := self makeClient ].
			self idleClients remove: mongoClient ifAbsent: [ nil ].
			mongoClient ifNotNil: [ self busyClients add: mongoClient ].
			mongoClient ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> reset [
	self busyClients copy
		do: [ :e | 
			e reset.
			self remove: e ].
	self idleClients copy
		do: [ :e | 
			e reset.
			self remove: e ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> returnClient: aMongoClient [
	"Sends aClient to go from the busy ones to the idle ones
	but only if it's still valid"

	self clientsMonitor
		critical: [ self busyClients
				remove: aMongoClient
				ifAbsent: [ self returningUnusedClient ].
			aMongoClient isValid
				ifTrue: [ self idleClients add: aMongoClient ] ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> start [
	^ self start: self minClients
]

{ #category : #actions }
MaplessStandaloneMongoPool >> start: anInteger [
	anInteger timesRepeat: [ self idleClients add: self makeClient ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> stop [
	self idleClients do: [ :each | each close ].
	[ self hasBusyClients ]
		whileTrue: [ 1 second wait.
			self stop ]
]

{ #category : #actions }
MaplessStandaloneMongoPool >> withClientDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle clients as parameter.
	Other code could reach the client in use by accessing
	the XXCurrentClient dynamic variable's value."

	| mongoClient |
	mongoClient := self requestClient.
	^ self currentClientDynamicVariable
		value: mongoClient
		during: [ [ [ aBlock value: mongoClient ]
				on: Error
				do: [ :x | 
					mongoClient reset.
					x pass ] ]
				ensure: [ self returnClient: mongoClient ] ]
]
