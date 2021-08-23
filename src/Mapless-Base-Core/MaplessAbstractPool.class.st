Class {
	#name : #MaplessAbstractPool,
	#superclass : #Object,
	#instVars : [
		'clientsMutex',
		'busyClients',
		'idleClients',
		'username',
		'password'
	],
	#classInstVars : [
		'instance'
	],
	#category : #'Mapless-Base-Core-Repositories'
}

{ #category : #initialization }
MaplessAbstractPool class >> initializeInstance [

	^ instance := self new
]

{ #category : #accessing }
MaplessAbstractPool class >> instance [ 

	^ instance ifNil:[self initializeInstance]
]

{ #category : #actions }
MaplessAbstractPool class >> reset [ 

	instance ifNotNil:[
		instance reset].
		
	instance := nil
]

{ #category : #accessing }
MaplessAbstractPool >> authenticationDatabaseName [
	^ OSEnvironment current at: 'DB_AUTH_NAME' ifAbsent: [ 'admin' ]
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

{ #category : #accessing }
MaplessAbstractPool >> databaseName [

	^ OSEnvironment default at: 'DB_NAME' ifAbsent: [ 'admin' ]
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

{ #category : #accessing }
MaplessAbstractPool >> idleClients [ 
	"Answers the bunch of clients that are currently idle"
	^ idleClients ifNil:[self initializeIdleClients]
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
MaplessAbstractPool >> initializePassword [
	^ password := OSEnvironment current
		at: 'DB_PASSWORD'
		ifAbsent: [ nil ]
]

{ #category : #initialization }
MaplessAbstractPool >> initializeUsername [
	^ username := OSEnvironment current
		at: 'DB_USERNAME'
		ifAbsent: [ nil ]
]

{ #category : #testing }
MaplessAbstractPool >> isUsingAuth [
	"Answers true if we can assume the client won't be using authentication mechanisms."

	^ self username notNil and: [ self password notNil ]
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
MaplessAbstractPool >> password [
	^ password ifNil: [ self initializePassword ]
]

{ #category : #accessing }
MaplessAbstractPool >> password: anObject [
	password := anObject
]

{ #category : #actions }
MaplessAbstractPool >> printOn: aStream [

	super printOn: aStream.
	
	aStream 
		nextPutAll: '(',self busyClients size asString,' busy, ',self idleClients size asString, ' idle)'
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
				ifFalse: [ self makeClient ].
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

{ #category : #accessing }
MaplessAbstractPool >> username [
	^ username ifNil: [ self initializeUsername ]
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
