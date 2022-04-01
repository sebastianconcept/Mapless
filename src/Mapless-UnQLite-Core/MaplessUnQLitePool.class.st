Class {
	#name : #MaplessUnQLitePool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'clientsMonitor',
		'busyClients',
		'idleClients',
		'clientsMutex',
		'maxClients',
		'databaseFileName'
	],
	#category : #'Mapless-UnQLite-Core-Connections'
}

{ #category : #'instance creation' }
MaplessUnQLitePool class >> defaultMaxClients [
	"Default maximum quantity of clients for the connection pool used in case no max was specified"

	^ 500
]

{ #category : #'instance creation' }
MaplessUnQLitePool class >> local [
	^ self shouldNotImplement
]

{ #category : #'instance creation' }
MaplessUnQLitePool class >> on: aFilePathString [
	^ self new
		databaseFileName: aFilePathString;
		yourself
]

{ #category : #accessing }
MaplessUnQLitePool >> busyClients [
	"Answers the bunch of clients that are currently busy"

	^ busyClients ifNil: [ self initializeBusyClients ]
]

{ #category : #accessing }
MaplessUnQLitePool >> clientsMonitor [
	"Answers the monitor used to protect clients usage"

	^ clientsMonitor ifNil: [ self initializeClientsMonitor ]
]

{ #category : #accessing }
MaplessUnQLitePool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MaplessUnQLiteCurrentClient
]

{ #category : #accessing }
MaplessUnQLitePool >> databaseFileName [
	^ databaseFileName
]

{ #category : #accessing }
MaplessUnQLitePool >> databaseFileName: anObject [
	databaseFileName := anObject
]

{ #category : #testing }
MaplessUnQLitePool >> hasBusyClients [
	"Answers true if this pool has, at least one, busy client"

	^ self busyClients notEmpty
]

{ #category : #testing }
MaplessUnQLitePool >> hasIdleClients [
	"Answers true if this pool has, at least one, idle client"

	^ self idleClients notEmpty
]

{ #category : #testing }
MaplessUnQLitePool >> hasMaxClients [
	^ self maxClients = self quantityOfClients
]

{ #category : #accessing }
MaplessUnQLitePool >> idleClients [
	"Answers the bunch of clients that are currently idle"

	^ idleClients ifNil: [ self initializeIdleClients ]
]

{ #category : #actions }
MaplessUnQLitePool >> ifUnavailablePurge: aMaplessPostgresClient [
	"Tests aMaplessPostgresClient and remove it from this pool if invalid."

	aMaplessPostgresClient isValid
		ifFalse: [ self remove: aMaplessPostgresClient ]
]

{ #category : #initialization }
MaplessUnQLitePool >> initializeBusyClients [
	^ busyClients := IdentitySet new
]

{ #category : #initialization }
MaplessUnQLitePool >> initializeClientsMonitor [
	^ clientsMonitor := Monitor new
]

{ #category : #initialization }
MaplessUnQLitePool >> initializeIdleClients [
	^ idleClients := IdentitySet new
]

{ #category : #initialization }
MaplessUnQLitePool >> initializeMaxClients [
	^ maxClients := self class defaultMaxClients
]

{ #category : #actions }
MaplessUnQLitePool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"

	^ MaplessUnQLiteClient on: self databaseFileName
]

{ #category : #accessing }
MaplessUnQLitePool >> maxClients [
	^ maxClients ifNil: [ self initializeMaxClients ]
]

{ #category : #reactions }
MaplessUnQLitePool >> onLogout: aMaplessUnQLiteClient [
	self remove: aMaplessUnQLiteClient
]

{ #category : #actions }
MaplessUnQLitePool >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			('({1} busy, {2} idle @ {3})'
				format:
					{self busyClients size asString.
					self idleClients size asString.
					databaseFileName asFileReference basename})
]

{ #category : #actions }
MaplessUnQLitePool >> purgeUnavailable [
	"Removes any client that might be expired or unreacheable."

	self busyClients copy do: [ :e | self ifUnavailablePurge: e ].
	self idleClients copy do: [ :e | self ifUnavailablePurge: e ]
]

{ #category : #accessing }
MaplessUnQLitePool >> quantityOfClients [
	^ self busyClients size + self idleClients size
]

{ #category : #actions }
MaplessUnQLitePool >> remove: aMaplessPostgresClient [
	aMaplessPostgresClient disconnect.
	self idleClients remove: aMaplessPostgresClient ifAbsent: [ nil ].
	self busyClients remove: aMaplessPostgresClient ifAbsent: [ nil ]
]

{ #category : #actions }
MaplessUnQLitePool >> requestClient [
	"Answers a unqliteClient instance taken from the idle clients.
	It'll create a new one if needed.
	It's a thread safe operation."

	^ self clientsMonitor
		critical: [ | unqliteClient |
			unqliteClient := self hasIdleClients
				ifTrue: [ self idleClients anyOne ]
				ifFalse: [ self hasMaxClients
						ifTrue: [ ^ MaplessMaximumPoolClientsReached signal ].
					self makeClient ].
			(unqliteClient notNil and: [ unqliteClient isValid not ])
				ifTrue: [ self remove: unqliteClient.
					unqliteClient := self makeClient ].
			self idleClients remove: unqliteClient ifAbsent: [ nil ].
			unqliteClient ifNotNil: [ self busyClients add: unqliteClient ].
			unqliteClient ]
]

{ #category : #actions }
MaplessUnQLitePool >> returnClient: aMaplessUnQLiteClient [
	"Sends aMaplessUnQLiteClient to go from the busy ones to the idle ones
	but only if it's still valid"

	self clientsMonitor
		critical: [ self busyClients
				remove: aMaplessUnQLiteClient
				ifAbsent: [ self returningUnusedClient ].
			aMaplessUnQLiteClient isValid
				ifTrue: [ self idleClients add: aMaplessUnQLiteClient ] ]
]

{ #category : #actions }
MaplessUnQLitePool >> returningUnusedClient [
	Transcript
		cr;
		show: 'Warning: returning a client that is not in among the busy ones'
]

{ #category : #actions }
MaplessUnQLitePool >> stop [
	self idleClients do: [ :each | each close ].
	[ self hasBusyClients ]
		whileTrue: [ 1 second wait.
			self stop ]
]

{ #category : #actions }
MaplessUnQLitePool >> withClientDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle clients as parameter.
	Other code could reach the client in use by accessing
	the XXCurrentClient dynamic variable's value."

	| unqliteClient |
	unqliteClient := self requestClient.
	^ self currentClientDynamicVariable
		value: unqliteClient
		during: [ [ [ aBlock value: unqliteClient ]
				on: Error
				do: [ :x | 
					unqliteClient reset.
					x pass ] ]
				ensure: [ self returnClient: unqliteClient ] ]
]
