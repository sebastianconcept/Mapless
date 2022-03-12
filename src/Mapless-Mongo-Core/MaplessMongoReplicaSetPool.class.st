"
I'm a pool of MongoDB clients that are connected to a Replica Set.
I use the secondary nodes for read-only operations and the primary node for the read-write operations.
I'm optimistic to resolve which available clients to use and I handle the exceptions as gracefully as I can when turns out that a primary suddenly is not available (replica set primary election).
"
Class {
	#name : #MaplessMongoReplicaSetPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'readOnlyProtection',
		'readWriteProtection',
		'idleReadOnlyClients',
		'idleReadWriteClients',
		'busyReadOnlyClients',
		'busyReadWriteClients',
		'resolver',
		'minReadWriteClients',
		'minReadOnlyClients',
		'maxReadWriteClients',
		'maxReadOnlyClients'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #accessing }
MaplessMongoReplicaSetPool class >> defaultMaxReadOnlyClients [
	"Default maximum quantity of read-only clients for the connection pool used in case no max was specified"

	^ 50
]

{ #category : #accessing }
MaplessMongoReplicaSetPool class >> defaultMaxReadWriteClients [
	"Default maximum quantity of read-write clients for the connection pool used in case no max was specified"

	^ 50
]

{ #category : #accessing }
MaplessMongoReplicaSetPool class >> defaultMinReadOnlyClients [
	"Default minimum quantity of read-only clients for the connection pool used in case no min was specified"

	^ 2
]

{ #category : #accessing }
MaplessMongoReplicaSetPool class >> defaultMinReadWriteClients [
	"Default minimum quantity of read-write clients for the connection pool used in case no min was specified"

	^ 2
]

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> mongoUrls: someMongoUrls database: databaseName [
	^ self
		mongoUrls: someMongoUrls asOrderedCollection
		database: databaseName
		username: ''
		password: ''
]

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> mongoUrls: someMongoUrls database: databaseName username: aUserName password: aPassword [
	^ self basicNew
		initializeMongoUrls: (someMongoUrls collect: #asMongoUrl)
			database: databaseName
			username: aUserName
			password: aPassword;
		yourself
]

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> test [
	"Answers a new pool handly for testing"

	^ self
		mongoUrls: {'localhost:27017' . 'localhost:27019'}
		database: 'Mapless-Test'
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> busyReadOnlyClients [
	"Answers the bunch of read-only clients that are currently busy"

	^ busyReadOnlyClients ifNil: [ self initializeBusyReadOnlyClients ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> busyReadWriteClients [
	"Answers the bunch of read-write clients that are currently busy"

	^ busyReadWriteClients ifNil: [ self initializeBusyReadWriteClients ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MongoCurrentClient
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureMinimumQuantityOfReadOnlyClients [
	^ self ensureReadOnly: self minReadOnlyClients
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureMinimumQuantityOfReadWriteClients [
	^ self ensureReadWrite: self minReadWriteClients
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureReadOnly: anInteger [
	| client |
	self idleReadOnlyClients size < anInteger
		ifTrue: [ (anInteger min: anInteger - self idleReadOnlyClients size)
				timesRepeat: [ client := self makeReadOnlyClient.
					client ifNotNil: [ self idleReadOnlyClients add: client ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureReadWrite: anInteger [
	| client |
	self idleReadWriteClients size < anInteger
		ifTrue: [ (anInteger min: anInteger - self idleReadWriteClients size)
				timesRepeat: [ client := self makeReadWriteClient.
					client ifNotNil: [ self idleReadWriteClients add: client ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> findPrimary [
	"Find the primary of the replica set"

	^ resolver findPrimaryFor: self
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> getCurrentPrimaryMongoUrl [
	"1. Does it have clients for each address? Use them to ask if it's primary 
	2. doesn't have clients to an address? Create one and ask if primary."
	
	self mongoUrls

]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> getReadOnlyMongoUrl [
	^ resolver getSecondaryMongoUrl
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> getReadWriteMongoUrl [
	^ resolver getPrimaryMongoUrl
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasBusyClients [
	"Answers true if this pool has, at least one, busy client"

	^ self busyReadOnlyClients notEmpty
		or: [ self busyReadWriteClients notEmpty ]
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasIdleReadOnlyClients [
	^ self idleReadOnlyClients notEmpty
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasIdleReadWriteClients [
	^ self idleReadWriteClients notEmpty
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasMaxReadOnlyClients [
	^ self maxReadOnlyClients = self quantityOfReadOnlyClients
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasMaxReadWriteClients [
	^ self maxReadWriteClients = self quantityOfReadWriteClients
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasPrimary [
	^ resolver hasPrimary
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> idleReadOnlyClients [
	^ idleReadOnlyClients ifNil: [ self initializeIdleReadOnlyClients ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> idleReadWriteClients [
	^ idleReadWriteClients ifNil: [ self initializeIdleReadWriteClients ]
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initialize [
	super initialize.
	readOnlyProtection := Mutex new.
	readWriteProtection := Mutex new.
	self
		when: #notPrimaryReadWriteAttempt
		send: #onNotPrimaryReadWriteAttempt:using:
		to: self.
	self when: #primaryFound send: #onPrimaryFound: to: self
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeBusyReadOnlyClients [
	^ busyReadOnlyClients := IdentitySet new
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeBusyReadWriteClients [
	^ busyReadWriteClients := IdentitySet new
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeIdleReadOnlyClients [
	^ idleReadOnlyClients := IdentitySet new
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeIdleReadWriteClients [
	^ idleReadWriteClients := IdentitySet new
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeMinReadOnlyClients [
	^ minReadOnlyClients := self class defaultMinReadOnlyClients
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeMinReadWriteClients [
	^ minReadWriteClients := self class defaultMinReadWriteClients
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeMongoUrls: someMongoUrls database: databaseName username: aUserName password: aPassword [
	self initialize.
	username := aUserName.
	password := aPassword.
	resolver := MaplessMongoResolver fromMongoUrls: someMongoUrls
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> makeClientWith: aMongoUrl [
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

{ #category : #actions }
MaplessMongoReplicaSetPool >> makeReadOnlyClient [
	^ self hasPrimary
		ifTrue: [ self makeClientWith: resolver getSecondaryMongoUrl ]
		ifFalse: [ nil ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> makeReadWriteClient [
	^ self hasPrimary
		ifTrue: [ self makeClientWith: resolver getPrimaryMongoUrl ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> maxReadOnlyClients [
	^ maxReadOnlyClients
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> maxReadOnlyClients: anObject [
	maxReadOnlyClients := anObject
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> maxReadWriteClients [
	^ maxReadWriteClients
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> maxReadWriteClients: anObject [
	maxReadWriteClients := anObject
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> minReadOnlyClients [
	^ minReadOnlyClients ifNil: [ self initializeMinReadOnlyClients ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> minReadOnlyClients: anObject [
	minReadOnlyClients := anObject
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> minReadWriteClients [
	^ minReadWriteClients ifNil: [ self initializeMinReadWriteClients ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> minReadWriteClients: anObject [
	minReadWriteClients := anObject
]

{ #category : #reactions }
MaplessMongoReplicaSetPool >> onNotPrimaryReadWriteAttempt: aBlock using: aMongoAPI [
	self removeInvalidClients.
	self ensureMinimumQuantityOfReadOnlyClients.
	self ensureMinimumQuantityOfReadWriteClients
]

{ #category : #reactions }
MaplessMongoReplicaSetPool >> onPrimaryFound: aMongoAPI [

	self removeInvalidClients.
	self ensureMinimumQuantityOfReadOnlyClients.
	self ensureMinimumQuantityOfReadWriteClients.
	
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			'(' , self busyReadOnlyClients size asString , ' busy R/O, '
				, self idleReadOnlyClients size asString , ' idle R/O, '
				, self busyReadWriteClients size asString , ' busy R/W, '
				, self idleReadWriteClients size asString , ' idle R/W)'
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> purge [
	self initializeIdleReadOnlyClients.
	self initializeIdleReadWriteClients.
	self initializeBusyReadOnlyClients.
	self initializeBusyReadWriteClients
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> quantityOfReadOnlyClients [
	^ self busyReadOnlyClients size + self idleReadOnlyClients size
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> quantityOfReadWriteClients [
	^ self busyReadWriteClients size + self idleReadWriteClients size
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readOnlyDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle read-only clients as parameter."

	| client |
	[ [ client := self requestReadOnlyClient.
	client ifNil: [ self readOnlyError: nil ].
	^ self currentClientDynamicVariable
		value: client
		during: [ [ aBlock value: client ]
				ensure: [ self returnReadOnlyClient: client ] ] ]
		on: NetworkError
		do: [ :x1 | 
			client ifNotNil: [ client reset ].
			self readOnlyError: x1 ] ]
		on: Error
		do: [ :x2 | 
			client ifNotNil: [ client reset ].
			x2 pass ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readOnlyError: anExceptionOrNil [
	resolver resetRoles.
	self removeInvalidReadOnlyClients.
	anExceptionOrNil
		ifNil: [ MaplessReadOnlyOperationFailed signal ]
		ifNotNil:
			[ MaplessReadOnlyOperationFailed signal: anExceptionOrNil messageText ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readWriteDo: aBlock [
	"Evaluates aBlock using one of the 
	(at the moment) idle read-write clients as parameter."

	| client |
	[ [ [ client := self requestReadWriteClient.
	client ifNil: [ self readWriteError: nil ].
	^ self currentClientDynamicVariable
		value: client
		during: [ [ aBlock value: client ]
				ensure: [ self returnReadWriteClient: client ] ] ]
		on: NetworkError
		do: [ :x1 | 
			client ifNotNil: [ client reset ].
			self readWriteError: x1 ] ]
		on: MongoNotMaster 
		do: [ :x2 | 
			client ifNotNil: [ client reset ].
			self
				triggerEvent: #notPrimaryReadWriteAttempt
				withArguments:
					{aBlock.
					client}.
			self readWriteError: x2 ] ]
		on: Error
		do: [ :x3 | 
			client ifNotNil: [ client reset ].
			x3 pass ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readWriteError: anExceptionOrNil [
	resolver resetRoles.
	self removeInvalidReadWriteClients.
	anExceptionOrNil
		ifNil: [ MaplessReadWriteOperationFailed signal ]
		ifNotNil:
			[ MaplessReadWriteOperationFailed signal: anExceptionOrNil messageText ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeInvalidClients [
	"Removes read-only clients that might be opened using the current address of a primary."

	self removeInvalidReadOnlyClients.
	self removeInvalidReadWriteClients.
	
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeInvalidReadOnlyClients [
	"Removes read-only clients that might be opened using the current address of a primary."

	| readOnlyUrls |
	readOnlyUrls := resolver secondaryMongoUrls contents.
	readOnlyProtection
		critical: [ self idleReadOnlyClients copy
				do: [ :each | 
					(each isAt: resolver primaryMongoUrl)
						ifTrue: [ self idleReadOnlyClients remove: each ifAbsent: [ nil ] ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeInvalidReadWriteClients [
	"Removes read-write clients that might be opened using other than the current address of the primary."

	readWriteProtection
		critical: [ self idleReadWriteClients copy
				do: [ :each | 
					(each isAt: resolver primaryMongoUrl)
						ifFalse: [ self idleReadWriteClients remove: each ifAbsent: [ nil ] ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeReadOnlyClient: aMongoAPI ifAbsent: aBlock [
	self idleReadOnlyClients remove: aMongoAPI ifAbsent: aBlock
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeReadWriteClient: aMongoAPI ifAbsent: aBlock [
	self idleReadWriteClients remove: aMongoAPI ifAbsent: aBlock
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> requestClientFor: aMongoUrl [
	^ self clientsMonitor
		critical: [ self unprotectedRequestClientFor: aMongoUrl ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> requestReadOnlyClient [
	^ readOnlyProtection
		critical: [ | client |
			self hasPrimary
				ifFalse: [ self findPrimary ].
			client := self hasIdleReadOnlyClients
				ifTrue: [ self idleReadOnlyClients anyOne ]
				ifFalse: [ self hasMaxReadOnlyClients
						ifTrue: [ ^ MaplessMaximumReadWritePoolClientsReached signal ].
					self makeReadOnlyClient ].
			(client notNil and: [ client isValid not ])
				ifTrue: [ self removeReadOnlyClient: client ifAbsent: [ nil ].
					client := self makeReadOnlyClient ].
			self removeReadOnlyClient: client ifAbsent: [ nil ].
			client ifNotNil: [ self busyReadOnlyClients add: client ].
			client ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> requestReadWriteClient [
	^ readWriteProtection
		critical: [ | client |
			self hasPrimary
				ifFalse: [ self findPrimary ].
			client := self hasIdleReadWriteClients
				ifTrue: [ self idleReadWriteClients anyOne ]
				ifFalse: [ self hasMaxReadWriteClients
						ifTrue: [ ^ MaplessMaximumReadWritePoolClientsReached signal ].
					self makeReadWriteClient ].
			(client notNil
				and: [ client isValid not or: [ client isPrimary not ] ])
				ifTrue: [ self removeReadWriteClient: client ifAbsent: [ nil ].
					client := self makeReadWriteClient ].
			self removeReadWriteClient: client ifAbsent: [ nil ].
			client ifNotNil: [ self busyReadWriteClients add: client ].
			client ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> returnReadOnlyClient: aMongoAPI [
	"Sends aMongoAPI to go from the busy ones to the idle ones
	but only if it's still valid and is still connected to a secondary."

	readOnlyProtection
		critical: [ self busyReadOnlyClients remove: aMongoAPI ifAbsent: [ nil ].
			(aMongoAPI isValid and: [ aMongoAPI isSecondary ])
				ifTrue: [ self idleReadOnlyClients add: aMongoAPI ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> returnReadWriteClient: aMongoAPIOrNil [
	"Sends aMongoAPI to go from the busy ones to the idle ones
	but only if it's still valid and is still a connected to the primary."

	aMongoAPIOrNil ifNil: [ ^ self ].
	readWriteProtection
		critical: [ self busyReadWriteClients remove: aMongoAPIOrNil ifAbsent: [ nil ].
			(aMongoAPIOrNil isValid and: [ aMongoAPIOrNil isPrimary ])
				ifTrue: [ self idleReadWriteClients add: aMongoAPIOrNil ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> start [
	self findPrimary
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> stop [
	
	self flag: #todo. "Stop for busy clients?"
	
	self idleReadOnlyClients do: [ :each | each close ].
	self idleReadWriteClients do: [ :each | each close ].
	
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> unprotectedRequestClientFor: aMongoUrl [
	| client |
	client := self idleReadOnlyClients
		detect: [ :each | each isAt: aMongoUrl ]
		ifNone: [ nil ].
	client
		ifNil: [ client := self idleReadWriteClients
				detect: [ :each | each isAt: aMongoUrl ]
				ifNone: [ nil ].
			client
				ifNotNil: [ self idleReadWriteClients remove: client ifAbsent: [ nil ].
					self busyReadWriteClients add: client ] ]
		ifNotNil: [ self idleReadOnlyClients remove: client ifAbsent: [ nil ].
			self busyReadOnlyClients add: client ].
	^ client
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> withClientDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client as aBlock argument."

	"Use the explicit read-only or read-write methods"

	self shouldNotImplement
]
