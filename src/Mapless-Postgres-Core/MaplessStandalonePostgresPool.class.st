Class {
	#name : #MaplessStandalonePostgresPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'databaseName',
		'clientsMonitor',
		'busyClients',
		'idleClients',
		'clientsMutex',
		'maxClients'
	],
	#category : #'Mapless-Postgres-Core-Connections'
}

{ #category : #'instance creation' }
MaplessStandalonePostgresPool class >> defaultMaxClients [
	"Default maximum quantity of clients for the connection pool used in case no max was specified"

	^ 500
]

{ #category : #'instance creation' }
MaplessStandalonePostgresPool class >> local [
	^ self
		hostname: 'localhost'
		port: 5432
		username: 'username'
		password: 'password'
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> busyClients [
	"Answers the bunch of clients that are currently busy"

	^ busyClients ifNil: [ self initializeBusyClients ]
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> clientsMonitor [
	"Answers the monitor used to protect clients usage"

	^ clientsMonitor ifNil: [ self initializeClientsMonitor ]
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MaplessPostgresCurrentClient
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> databaseName [
	^ databaseName
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> databaseName: anObject [
	databaseName := anObject
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> getConnectionUrl [
	^ ZnUrl new
		scheme: 'psql';
		host: hostname;
		port: port;
		username: username;
		password: password;
		/ databaseName
]

{ #category : #testing }
MaplessStandalonePostgresPool >> hasBusyClients [
	"Answers true if this pool has, at least one, busy client"

	^ self busyClients notEmpty
]

{ #category : #testing }
MaplessStandalonePostgresPool >> hasIdleClients [
	"Answers true if this pool has, at least one, idle client"

	^ self idleClients notEmpty
]

{ #category : #testing }
MaplessStandalonePostgresPool >> hasMaxClients [
	^ self maxClients = self quantityOfClients
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> idleClients [
	"Answers the bunch of clients that are currently idle"

	^ idleClients ifNil: [ self initializeIdleClients ]
]

{ #category : #actions }
MaplessStandalonePostgresPool >> ifUnavailablePurge: aMaplessPostgresClient [
	"Tests aMaplessPostgresClient and remove it from this pool if invalid."

	aMaplessPostgresClient isValid
		ifFalse: [ self remove: aMaplessPostgresClient ]
]

{ #category : #initialization }
MaplessStandalonePostgresPool >> initializeBusyClients [
	^ busyClients := IdentitySet new
]

{ #category : #initialization }
MaplessStandalonePostgresPool >> initializeClientsMonitor [
	^ clientsMonitor := Monitor new
]

{ #category : #initialization }
MaplessStandalonePostgresPool >> initializeIdleClients [
	^ idleClients := IdentitySet new
]

{ #category : #initialization }
MaplessStandalonePostgresPool >> initializeMaxClients [
	^ maxClients := self class defaultMaxClients
]

{ #category : #actions }
MaplessStandalonePostgresPool >> makeClient [
	"Returns a new client that can be (re)used in the pool"

	^ (MaplessPostgresClient url: self getConnectionUrl) connect
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> maxClients [
	^ maxClients ifNil: [ self initializeMaxClients ]
]

{ #category : #reactions }
MaplessStandalonePostgresPool >> onLogout: aMaplessPostgresClient [
	self remove: aMaplessPostgresClient
]

{ #category : #actions }
MaplessStandalonePostgresPool >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			'(' , self busyClients size asString , ' busy, '
				, self idleClients size asString , ' idle @' , databaseName , ')'
]

{ #category : #actions }
MaplessStandalonePostgresPool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."

	self busyClients copy do: [ :e | self ifUnavailablePurge: e ].
	self idleClients copy do: [ :e | self ifUnavailablePurge: e ]
]

{ #category : #accessing }
MaplessStandalonePostgresPool >> quantityOfClients [
	^ self busyClients size + self idleClients size
]

{ #category : #actions }
MaplessStandalonePostgresPool >> remove: aMaplessPostgresClient [
	aMaplessPostgresClient disconnect.
	self idleClients remove: aMaplessPostgresClient ifAbsent: [ nil ].
	self busyClients remove: aMaplessPostgresClient ifAbsent: [ nil ]
]

{ #category : #actions }
MaplessStandalonePostgresPool >> requestClient [
	"Answers a postgresClient instance taken from the idle clients.
	It'll create a new one if needed.
	It's a thread safe operation."

	^ self clientsMonitor
		critical: [ | postgresClient |
			postgresClient := self hasIdleClients
				ifTrue: [ self idleClients anyOne ]
				ifFalse: [ self hasMaxClients
						ifTrue: [ ^ MaplessMaximumPoolClientsReached signal ].
					self makeClient ].
			(postgresClient notNil and: [ postgresClient isValid not ])
				ifTrue: [ self remove: postgresClient.
					postgresClient := self makeClient ].
			self idleClients remove: postgresClient ifAbsent: [ nil ].
			postgresClient ifNotNil: [ self busyClients add: postgresClient ].
			postgresClient ]
]

{ #category : #actions }
MaplessStandalonePostgresPool >> returnClient: aMaplessPostgresClient [
	"Sends aMaplessPostgresClient to go from the busy ones to the idle ones
	but only if it's still valid"

	self clientsMonitor
		critical: [ self busyClients
				remove: aMaplessPostgresClient
				ifAbsent: [ self returningUnusedClient ].
			aMaplessPostgresClient isValid
				ifTrue: [ self idleClients add: aMaplessPostgresClient ] ]
]

{ #category : #actions }
MaplessStandalonePostgresPool >> returningUnusedClient [
	Transcript
		cr;
		show: 'Warning: returning a client that is not in among the busy ones'
]

{ #category : #actions }
MaplessStandalonePostgresPool >> stop [
	self idleClients do: [ :each | each close ].
	[ self hasBusyClients ]
		whileTrue: [ 1 second wait.
			self stop ]
]

{ #category : #actions }
MaplessStandalonePostgresPool >> withClientDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle clients as parameter.
	Other code could reach the client in use by accessing
	the XXCurrentClient dynamic variable's value."

	| postgresClient |
	postgresClient := self requestClient.
	^ self currentClientDynamicVariable
		value: postgresClient
		during: [ [ [ aBlock value: postgresClient ]
				on: Error
				do: [ :x | 
					postgresClient reset.
					x pass ] ]
				ensure: [ self returnClient: postgresClient ] ]
]
