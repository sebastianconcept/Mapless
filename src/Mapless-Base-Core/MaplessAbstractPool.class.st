"
This is the abstraction that Mapless uses to have pools of clients to the database connections.
See subclasses for concrete accessors.
"
Class {
	#name : #MaplessAbstractPool,
	#superclass : #Object,
	#instVars : [
		'maxClients',
		'clientsMutex',
		'busyClients',
		'idleClients',
		'hostname',
		'port',
		'username',
		'password',
		'authenticationDatabaseName'
	],
	#category : #'Mapless-Base-Core-Repositories'
}

{ #category : #'instance creation' }
MaplessAbstractPool class >> defaultMaxClients [
	"Default maximum quantity of clients for the connection pool used in case no max was specified"

	^ 50
]

{ #category : #'instance creation' }
MaplessAbstractPool class >> hostname: aString port: anInteger [
	^ self
		hostname: aString
		port: anInteger
		username: nil
		password: nil
]

{ #category : #'instance creation' }
MaplessAbstractPool class >> hostname: aString port: anInteger username: anUsernameOrNil password: aPasswordOrNil [
	^ self new
		hostname: aString;
		port: anInteger;
		username: anUsernameOrNil;
		password: aPasswordOrNil;
		yourself
]

{ #category : #'instance creation' }
MaplessAbstractPool class >> local [
	^ self
		hostname: 'localhost'
		port: 27017
		username: nil
		password: nil
]

{ #category : #accessing }
MaplessAbstractPool >> allClients [
	^ self busyClients , self idleClients
]

{ #category : #accessing }
MaplessAbstractPool >> authenticationDatabaseName [
	^ authenticationDatabaseName
		ifNil: [ self initializeAuthenticationDatabaseName ]
]

{ #category : #accessing }
MaplessAbstractPool >> authenticationDatabaseName: aString [
	authenticationDatabaseName := aString
]

{ #category : #accessing }
MaplessAbstractPool >> busyClients [ 
	"Answers the bunch of clients that are currently busy"
	^ busyClients ifNil:[self initializeBusyClients]
]

{ #category : #accessing }
MaplessAbstractPool >> clientsMutex [
	"Answers the mutex used to protect clients usage"
	^ clientsMutex ifNil: [self initializeClientsMutex]
]

{ #category : #accessing }
MaplessAbstractPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."
	^ self subclassResponsibility 
]

{ #category : #actions }
MaplessAbstractPool >> do: aBlock [
	"Evaluates aBlock using a client"

	^ self withClientDo: aBlock 

]

{ #category : #testing }
MaplessAbstractPool >> hasBusyClients [
	"Answers true if this pool has, at least one, busy client"
	^ self busyClients notEmpty
]

{ #category : #testing }
MaplessAbstractPool >> hasClients [
	"Answers true if this pool has at least one client"
	^ self hasIdleClients or:[
	self hasBusyClients]
]

{ #category : #testing }
MaplessAbstractPool >> hasIdleClients [
	"Answers true if this pool has, at least one, idle client"
	^ self idleClients notEmpty
]

{ #category : #testing }
MaplessAbstractPool >> hasMaxClients [
	^ self maxClients = self quantityOfClients
]

{ #category : #accessing }
MaplessAbstractPool >> hostname [
	^ hostname
]

{ #category : #accessing }
MaplessAbstractPool >> hostname: anObject [
	hostname := anObject
]

{ #category : #accessing }
MaplessAbstractPool >> idleClients [ 
	"Answers the bunch of clients that are currently idle"
	^ idleClients ifNil:[self initializeIdleClients]
]

{ #category : #initialization }
MaplessAbstractPool >> initializeAuthenticationDatabaseName [
	^ authenticationDatabaseName := 'admin'
]

{ #category : #initialization }
MaplessAbstractPool >> initializeBusyClients [

	^ busyClients := IdentitySet new
]

{ #category : #initialization }
MaplessAbstractPool >> initializeClientsMutex [

	^ clientsMutex := Semaphore forMutualExclusion
]

{ #category : #initialization }
MaplessAbstractPool >> initializeIdleClients [

	^ idleClients := IdentitySet new
]

{ #category : #initialization }
MaplessAbstractPool >> initializeMaxClients [
	^ maxClients := self class defaultMaxClients
]

{ #category : #testing }
MaplessAbstractPool >> isUsingAuth [
	^ username notNil and: [ password notNil ]
]

{ #category : #actions }
MaplessAbstractPool >> logNewClient: mongoClient [
	
	Stdio stderr
		lf;
		<< ('Created mongo client ' , mongoClient printString);
		flush
]

{ #category : #actions }
MaplessAbstractPool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"
	^ self subclassResponsibility 
]

{ #category : #accessing }
MaplessAbstractPool >> maxClients [
	^ maxClients ifNil: [ self initializeMaxClients ]
]

{ #category : #accessing }
MaplessAbstractPool >> maxClients: anInteger [
	maxClients := anInteger
]

{ #category : #accessing }
MaplessAbstractPool >> password [
	^ password
]

{ #category : #accessing }
MaplessAbstractPool >> password: anObject [
	password := anObject
]

{ #category : #accessing }
MaplessAbstractPool >> port [
	^ port
]

{ #category : #accessing }
MaplessAbstractPool >> port: anObject [
	port := anObject
]

{ #category : #actions }
MaplessAbstractPool >> printOn: aStream [

	super printOn: aStream.
	
	aStream 
		nextPutAll: '(',self busyClients size asString,' busy, ',self idleClients size asString, ' idle)'
]

{ #category : #accessing }
MaplessAbstractPool >> quantityOfClients [
	^ self busyClients size + self idleClients size
]

{ #category : #actions }
MaplessAbstractPool >> remove: aClient [

	self idleClients remove: aClient ifAbsent:[ nil ].
	self busyClients remove: aClient ifAbsent:[ nil ].
	
]

{ #category : #actions }
MaplessAbstractPool >> requestClient [
	"Answers a aClient instance taken from the idle clients.
	It'll create a new one if needed.
	It's a thread safe operation."

	^ self clientsMutex
		critical: [ | client |
			client := self hasIdleClients
				ifTrue: [ self idleClients anyOne ]
				ifFalse: [ self hasMaxClients
						ifTrue: [ ^ MaplessMaximumPoolClientsReached signal ].
					self makeClient ].
			(client notNil and: [ client isValid not ])
				ifTrue: [ self remove: client.
					client := self makeClient ].
			self idleClients remove: client ifAbsent: [ nil ].
			client ifNotNil: [ self busyClients add: client ].
			client ]
]

{ #category : #actions }
MaplessAbstractPool >> reset [ 

	self busyClients copy do:[ :e | 
		e reset. 
		self remove: e ].

	self idleClients copy do:[ :e | 
		e reset.
		self remove: e ].
]

{ #category : #actions }
MaplessAbstractPool >> returnClient: aClient [
	"Sends aClient to go from the busy ones to the idle ones
	but only if it's still valid"

	self clientsMutex
		critical: [ 
			self busyClients remove: aClient ifAbsent: [ self returningUnusedClient ].
			aClient isValid
				ifTrue: [ self idleClients add: aClient ] ]
]

{ #category : #actions }
MaplessAbstractPool >> returningUnusedClient [

	Transcript cr; show: 'Warning: returning a client that is not in among the busy ones'

]

{ #category : #actions }
MaplessAbstractPool >> start [

	^ self start: 2
]

{ #category : #actions }
MaplessAbstractPool >> start: anInteger [
	anInteger timesRepeat: [ self idleClients add: self makeClient ]
]

{ #category : #actions }
MaplessAbstractPool >> stop [
	self idleClients do: [ :each | each close ].
	[ self hasBusyClients ]
		whileTrue: [ 1 second wait.
			self stop ]
]

{ #category : #accessing }
MaplessAbstractPool >> username [
	^ username
]

{ #category : #accessing }
MaplessAbstractPool >> username: anObject [
	username := anObject
]

{ #category : #actions }
MaplessAbstractPool >> withClientDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle clients as parameter.
	Other code could reach the client in use by accessing
	the XXCurrentClient dynamic variable's value."

	| client |
	client := self requestClient.
	^ self currentClientDynamicVariable
		value: client
		during: [ [ [ aBlock value: client ]
				on: Error
				do: [ :x | 
					client reset.
					MongoOperationError signal: x messageText] ]
				ensure: [ self returnClient: client ] ]
]
