"
Connection pool for the Mapless repository using SQLite
"
Class {
	#name : #MaplessSQLitePool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'databaseName',
		'clientsMonitor',
		'busyClients',
		'idleClients',
		'clientsMutex',
		'maxClients',
		'databaseFilenameOrKeyword'
	],
	#category : #'Mapless-SQLite-Core'
}

{ #category : #'instance creation' }
MaplessSQLitePool class >> defaultMaxClients [
	"Default maximum quantity of clients for the connection pool used in case no max was specified"

	^ 50
]

{ #category : #'instance creation' }
MaplessSQLitePool class >> local [
	^ self memory
]

{ #category : #'instance creation' }
MaplessSQLitePool class >> memory [
	^ self new initializeOn: ':memory:'
]

{ #category : #'instance creation' }
MaplessSQLitePool class >> on: aDatabaseFilename [
	^ self new initializeOn: aDatabaseFilename
]

{ #category : #accessing }
MaplessSQLitePool >> busyClients [
	"Answers the bunch of clients that are currently busy"

	^ busyClients ifNil: [ self initializeBusyClients ]
]

{ #category : #accessing }
MaplessSQLitePool >> clientsMonitor [
	"Answers the monitor used to protect clients usage"

	^ clientsMonitor ifNil: [ self initializeClientsMonitor ]
]

{ #category : #accessing }
MaplessSQLitePool >> currentClientDynamicVariableClass [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MaplessSQLiteCurrentClient
]

{ #category : #accessing }
MaplessSQLitePool >> databaseName [
	^ databaseName
]

{ #category : #accessing }
MaplessSQLitePool >> databaseName: anObject [
	databaseName := anObject
]

{ #category : #testing }
MaplessSQLitePool >> hasBusyClients [
	"Answers true if this pool has, at least one, busy client"

	^ self busyClients notEmpty
]

{ #category : #testing }
MaplessSQLitePool >> hasIdleClients [
	"Answers true if this pool has, at least one, idle client"

	^ self idleClients notEmpty
]

{ #category : #testing }
MaplessSQLitePool >> hasMaxClients [
	^ self maxClients = self quantityOfClients
]

{ #category : #accessing }
MaplessSQLitePool >> idleClients [
	"Answers the bunch of clients that are currently idle"

	^ idleClients ifNil: [ self initializeIdleClients ]
]

{ #category : #actions }
MaplessSQLitePool >> ifUnavailablePurge: aMaplessDbClient [
	"Tests aMaplessDbClient and remove it from this pool if invalid."

	aMaplessDbClient isValid
		ifFalse: [ self remove: aMaplessDbClient ]
]

{ #category : #initialization }
MaplessSQLitePool >> initializeBusyClients [
	^ busyClients := IdentitySet new
]

{ #category : #initialization }
MaplessSQLitePool >> initializeClientsMonitor [
	^ clientsMonitor := Monitor new
]

{ #category : #initialization }
MaplessSQLitePool >> initializeIdleClients [
	^ idleClients := IdentitySet new
]

{ #category : #initialization }
MaplessSQLitePool >> initializeMaxClients [
	^ maxClients := self class defaultMaxClients
]

{ #category : #initialization }
MaplessSQLitePool >> initializeOn: aDatabaseFilenameOrKeyword [
	databaseFilenameOrKeyword := aDatabaseFilenameOrKeyword
]

{ #category : #actions }
MaplessSQLitePool >> makeClient [
	"Returns a new client that can be (re)used in the pool"

	^ MaplessSQLiteClient openOn: databaseFilenameOrKeyword
]

{ #category : #accessing }
MaplessSQLitePool >> maxClients [
	^ maxClients ifNil: [ self initializeMaxClients ]
]

{ #category : #reactions }
MaplessSQLitePool >> onLogout: maplessDbClient [
	self remove: maplessDbClient
]

{ #category : #actions }
MaplessSQLitePool >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			'(' , self busyClients size asString , ' busy, '
				, self idleClients size asString , ' idle @'
				, databaseFilenameOrKeyword , ')'
]

{ #category : #actions }
MaplessSQLitePool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."

	self busyClients copy do: [ :e | self ifUnavailablePurge: e ].
	self idleClients copy do: [ :e | self ifUnavailablePurge: e ]
]

{ #category : #accessing }
MaplessSQLitePool >> quantityOfClients [
	^ self busyClients size + self idleClients size
]

{ #category : #actions }
MaplessSQLitePool >> remove: aMaplessDbClient [
	aMaplessDbClient disconnect.
	self idleClients remove: aMaplessDbClient ifAbsent: [ nil ].
	self busyClients remove: aMaplessDbClient ifAbsent: [ nil ]
]

{ #category : #actions }
MaplessSQLitePool >> requestClient [
	"Answers a mapless db client instance taken from the idle clients.
	It'll create a new one if needed.
	It's a thread safe operation."

	^ self clientsMonitor
		critical: [ | maplessDbClient |
			maplessDbClient := self hasIdleClients
				ifTrue: [ self idleClients anyOne ]
				ifFalse: [ self hasMaxClients
						ifTrue: [ ^ MaplessMaximumPoolClientsReached signal ].
					self makeClient ].
			(maplessDbClient notNil and: [ maplessDbClient isValid not ])
				ifTrue: [ self remove: maplessDbClient.
					maplessDbClient := self makeClient ].
			self idleClients remove: maplessDbClient ifAbsent: [ nil ].
			maplessDbClient ifNotNil: [ self busyClients add: maplessDbClient ].
			maplessDbClient ]
]

{ #category : #actions }
MaplessSQLitePool >> returnClient: maplessDbClient [
	"Sends mapless db client to go from the busy ones to the idle ones
	but only if it's still valid"

	self clientsMonitor
		critical: [ self busyClients
				remove: maplessDbClient
				ifAbsent: [ self returningUnusedClient ].
			maplessDbClient isValid
				ifTrue: [ self idleClients add: maplessDbClient ] ]
]

{ #category : #actions }
MaplessSQLitePool >> returningUnusedClient [
	Transcript
		cr;
		show: 'Warning: returning a client that is not in among the busy ones'
]

{ #category : #actions }
MaplessSQLitePool >> stop [
	self idleClients do: [ :each | each close ].
	[ self hasBusyClients ]
		whileTrue: [ 1 second wait.
			self stop ]
]

{ #category : #actions }
MaplessSQLitePool >> withClientDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle clients as parameter.
	Other code could reach the client in use by accessing
	the XXCurrentClient dynamic variable's value."

	| maplessDbClient |
	maplessDbClient := self requestClient.
	^ self currentClientDynamicVariableClass
		value: maplessDbClient
		during: [ [ [ aBlock value: maplessDbClient ]
				on: Error
				do: [ :x | 
					maplessDbClient reset.
					x pass ] ]
				ensure: [ self returnClient: maplessDbClient ] ]
]
