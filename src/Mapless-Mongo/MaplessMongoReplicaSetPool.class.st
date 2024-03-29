"
I'm a pool of MongoDB clients that are connected to a Replica Set.
I use the secondary nodes for read-only operations and the primary node for the read-write operations.
I'm optimistic to resolve which available clients to use and I handle the exceptions as gracefully as I can when turns out that a primary suddenly is not available (replica set primary election).
"
Class {
	#name : #MaplessMongoReplicaSetPool,
	#superclass : #MaplessAbstracMongoPool,
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
		'maxReadOnlyClients',
		'loadBalancer',
		'healthChecker',
		'healthCheckerInterval'
	],
	#category : #'Mapless-Mongo-Connections'
}

{ #category : #default }
MaplessMongoReplicaSetPool class >> defaultHealthCheckInterval [
	"Default interval in seconds for checking the health of the replica set."

	^ 30
]

{ #category : #default }
MaplessMongoReplicaSetPool class >> defaultMaxReadOnlyClients [
	"Default maximum quantity of read-only clients for the connection pool used in case no max was specified"

	^ 50
]

{ #category : #default }
MaplessMongoReplicaSetPool class >> defaultMaxReadWriteClients [
	"Default maximum quantity of read-write clients for the connection pool used in case no max was specified"

	^ 50
]

{ #category : #default }
MaplessMongoReplicaSetPool class >> defaultMinReadOnlyClients [
	"Default minimum quantity of read-only clients for the connection pool used in case no min was specified"

	^ 4
]

{ #category : #default }
MaplessMongoReplicaSetPool class >> defaultMinReadWriteClients [
	"Default minimum quantity of read-write clients for the connection pool used in case no min was specified"

	^ 2
]

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> fromString: aStringOfOptionalWeigthsAndMongoUrls database: databaseName [
	| parts weights mongoUrls url weight |
	weights := Dictionary new.
	parts := aStringOfOptionalWeigthsAndMongoUrls substrings: ','.
	parts := parts collect: [ :each | each substrings: '@' ].
	parts
		do: [ :each | 
			each size > 1
				ifTrue: [ url := each second.
					weight := each first asNumber ]
				ifFalse: [ url := each first.
					weight := 1 ].
			weights at: url asMongoUrl put: weight ].
	mongoUrls := weights keys.
	^ self mongoUrls: mongoUrls weights: weights database: databaseName
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
MaplessMongoReplicaSetPool class >> mongoUrls: someMongoUrls weights: weightsDictionary database: databaseName [
	^ self
		mongoUrls: someMongoUrls
		weights: weightsDictionary
		database: databaseName
		username: ''
		password: ''
]

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> mongoUrls: someMongoUrls weights: weightsDictionary database: databaseName username: aUserName password: aPassword [
	^ self basicNew
		initializeMongoUrls: (someMongoUrls collect: #asMongoUrl)
			weights: weightsDictionary
			database: databaseName
			username: aUserName
			password: aPassword;
		yourself
]

{ #category : #'instance creation' }
MaplessMongoReplicaSetPool class >> test [
	"Answers a new pool handly for testing"

	^ self
		mongoUrls: {'mongo1:27017' . 'mongo2:27018' . 'mongo3:27019' . 'mongo4:27020'}
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
MaplessMongoReplicaSetPool >> countClientsTo: aMongoUrl [
	^ {idleReadOnlyClients.
	idleReadWriteClients.
	busyReadOnlyClients.
	busyReadWriteClients}
		inject: 0
		into: [ :sum :clients | 
			sum
				+
					(clients
						inject: 0
						into: [ :s :api | 
							api asMongoUrl = aMongoUrl
								ifTrue: [ s + 1 ]
								ifFalse: [ s ] ]) ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> currentClientDynamicVariableClass [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ MongoCurrentClient
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureClients [
	"Make sure that all types of connections have the minimum number 
	of clients and that any clients that may have been in a different role are removed."

	self ensurePrimaryClients.
	self ensureSecondaryClients
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
MaplessMongoReplicaSetPool >> ensurePrimaryClients [
	"Make sure the primary has the minimum number of 
	clients and that any clients that may have been in a different role are removed."


	| primaryUrl |
	primaryUrl := resolver primaryUrl.
	readWriteProtection
		critical: [ idleReadWriteClients copy
				do: [ :client | 
					client asMongoUrl ~= primaryUrl
						ifTrue: [ idleReadWriteClients remove: client ifAbsent: [ nil ].
							self silentlyClose: client ] ].
			busyReadWriteClients copy
				do: [ :client | 
					client asMongoUrl ~= primaryUrl
						ifTrue: [ idleReadWriteClients remove: client ifAbsent: [ nil ].
							self silentlyClose: client ] ].
			self ensureMinimumQuantityOfReadWriteClients ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureReadOnly: anInteger [
	"Makes sure that each secondary has at least anInteger quantity of idle clients."

	| readOnlyClientsMongoUrls found client |
	readOnlyClientsMongoUrls := resolver secondaryUrls.
	readOnlyClientsMongoUrls
		do: [ :mongoUrl | 
			found := self idleReadOnlyClients
				select: [ :each | each asMongoUrl = mongoUrl ].
			found size <= anInteger
				ifTrue: [ (anInteger - found size min: anInteger)
						timesRepeat: [ client := self makeClientWith: mongoUrl.
							client ifNotNil: [ self idleReadOnlyClients add: client ] ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureReadWrite: anInteger [				
				
	| client |
	self idleReadWriteClients size <= anInteger
		ifTrue: [ (anInteger min: anInteger - self idleReadWriteClients size)
				timesRepeat: [ client := self makeReadWriteClient.
					client ifNotNil: [ self idleReadWriteClients add: client ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> ensureSecondaryClients [
	"Make sure that secondaries have the minimum number of 
	clients and that any clients that may have been in a different role are removed."

	| readOnlyClientsMongoUrls |
	readOnlyProtection
		critical: [ readOnlyClientsMongoUrls := resolver secondaryUrls.
			idleReadOnlyClients copy
				do: [ :client | 
					(readOnlyClientsMongoUrls includes: client asMongoUrl)
						ifFalse: [ idleReadOnlyClients remove: client ifAbsent: [ nil ].
							self silentlyClose: client ] ].
			busyReadOnlyClients copy
				do: [ :client | 
					(readOnlyClientsMongoUrls includes: client asMongoUrl)
						ifFalse: [ busyReadOnlyClients remove: client ifAbsent: [ nil ].
							self silentlyClose: client ] ].
			self ensureMinimumQuantityOfReadOnlyClients ]
]

{ #category : #healthcheck }
MaplessMongoReplicaSetPool >> ensureTopology [
	"Makes sure the resolver topology matches the one informed by the replica set,
	following this procedure:
	1. If it doesn't know the primary, find it.
	2. If it knows the primary but a client can't reach it, raise an exception.
	3. Ask the replica set about its members status.
	4. If the primary node is not the one the resolver has, make the resolver update itself.
	5. Update the resolver about the addresses of the secondaries."

	| client primaryUrl |
	resolver hasPrimary
		ifFalse: [ resolver findPrimaryFor: self ].
	primaryUrl := resolver primaryUrl.
	client := self makeClientWith: primaryUrl.
	client
		ifNil: [ resolver resetRoles.
			ReplicaSetPrimaryNotFound
				signal: 'Primary node could not be reached.' ].
	resolver updateStatusFrom: client.
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> findPrimary [
	"Find the primary of the replica set"

	^ resolver findPrimaryFor: self
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> getIdleReadOnlyClient [
	"Answers the next MongoDB client from among the idle,
	read-only ones, according to the load balancer.
	Return 'nil' if none can be found."

	| idleReadOnlyClientUrls selectedUrl |
	idleReadOnlyClientUrls := idleReadOnlyClients
		collect: [ :each | each mongoUrl ].
	idleReadOnlyClientUrls ifEmpty: [ ^ nil ].
	selectedUrl := loadBalancer
		nextAmong: (Array withAll: idleReadOnlyClientUrls asArray).
	^ idleReadOnlyClients
		detect: [ :e | 
			e mongoUrl port = selectedUrl port
				and: [ e mongoUrl host = selectedUrl host ] ]
		ifNone: [ nil ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> getIdleReadWriteClient [
	^ idleReadWriteClients anyOne
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> getPrimaryUrl [

	^ resolver primaryUrl
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> getSecondaryUrl [
	"Answers a MongoURL to a secondary.
	It chooses which one based on what the load balancer says."

	^ loadBalancer nextAmong: (Set newFrom: resolver secondaryUrls)
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasBusyClients [
	"Answers true if this pool has, at least one, busy client"

	^ self busyReadOnlyClients notEmpty
		or: [ self busyReadWriteClients notEmpty ]
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> hasHealthChecker [
	^ true
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
MaplessMongoReplicaSetPool >> healthChecker [
	^ healthChecker
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> healthCheckerInterval [
	^ healthCheckerInterval
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> healthCheckerInterval: anObject [
	healthCheckerInterval := anObject
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
	self initializeBusyReadWriteClients.
	self initializeBusyReadOnlyClients.
	self initializeIdleReadWriteClients.
	self initializeIdleReadOnlyClients.
	healthCheckerInterval := self class defaultHealthCheckInterval.
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
MaplessMongoReplicaSetPool >> initializeMaxReadOnlyClients [

	^ maxReadOnlyClients := self class defaultMaxReadOnlyClients
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeMaxReadWriteClients [

	^ maxReadWriteClients := self class defaultMaxReadWriteClients
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
	resolver := MaplessMongoReplicaSetResolver fromMongoUrls: someMongoUrls.
	resolver when: #rolesUpdated send: #onResolverUpdated to: self.
	loadBalancer := self newTrivialLoadBalancer
]

{ #category : #initialization }
MaplessMongoReplicaSetPool >> initializeMongoUrls: someMongoUrls weights: weightsDictionary database: databaseName username: aUserName password: aPassword [
	self initialize.
	username := aUserName.
	password := aPassword.
	resolver := MaplessMongoReplicaSetResolver fromMongoUrls: someMongoUrls.
	resolver when: #rolesUpdated send: #onResolverUpdated to: self.
	loadBalancer := MaplessWeightedRandomPolicy
		fromDictionary: weightsDictionary
		seed: DateAndTime now asUnixTime
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> isReadOnlyHealthy: aMongoUrl [
	"Answers true if aMongoUrl can be used as a healthy read-only connection."

	| client |
	client := self makeClientWith: aMongoUrl.
	^ [ client notNil
		and: [ client isValid
				and: [ client isSecondary
						and:
							[ (MongoDatabase root: client name: 'admin') collectionNames notEmpty ] ] ] ]
		ensure: [ client ifNotNil: [ client close ] ]
]

{ #category : #testing }
MaplessMongoReplicaSetPool >> isReadWriteHealthy: aMongoUrl [
	"Answers true if aMongoUrl can be used as a healthy read-write connection."

	| client |
	client := self makeClientWith: aMongoUrl.
	^ [ client notNil
		and: [ client isValid
				and: [ client isPrimary
						and:
							[ (MongoDatabase root: client name: 'admin') collectionNames notEmpty ] ] ] ]
		ensure: [ client ifNotNil: [ client close ] ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> loadBalancer [
	^ loadBalancer
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> makeClientWith: aMongoUrl [
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

{ #category : #actions }
MaplessMongoReplicaSetPool >> makeReadOnlyClient [
	^ self hasPrimary
		ifTrue: [ self makeClientWith: self getSecondaryUrl ]
		ifFalse: [ nil ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> makeReadWriteClient [
	^ self hasPrimary
		ifTrue: [ self makeClientWith: self getPrimaryUrl ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> maxReadOnlyClients [

	^ maxReadOnlyClients ifNil: [ self initializeMaxReadOnlyClients ]
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> maxReadOnlyClients: anObject [
	maxReadOnlyClients := anObject
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> maxReadWriteClients [

	^ maxReadWriteClients ifNil: [ self initializeMaxReadWriteClients ]
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

{ #category : #actions }
MaplessMongoReplicaSetPool >> newTrivialLoadBalancer [
	"Answers a new load balancer that will have equal chances of 
	selecting any client (weight 1 for all urls)."

	| weights |
	weights := [ :dic | 
	resolver mongoUrls do: [ :url | dic at: url asMongoUrl put: 1 ].
	dic ] value: Dictionary new.
	^ MaplessWeightedRandomPolicy
		fromDictionary: weights
		seed: DateAndTime now asUnixTime
]

{ #category : #reactions }
MaplessMongoReplicaSetPool >> onClientClosed: aMongoAPI [
	self triggerEvent: #clientClosed: with: aMongoAPI
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
	self replicaSetAvailabilityHealthcheck.
	
]

{ #category : #reactions }
MaplessMongoReplicaSetPool >> onResolverUpdated [

	self ensureClients
]

{ #category : #healthcheck }
MaplessMongoReplicaSetPool >> primaryAvailabilityHealthcheck [
	"Raise proper exceptions (to be handled) if any of these check fails:
	1. Primary can be reached.
	2. Primary can be used."

	| client primaryUrl adminDb usersCollection |
	"1. Primary can be reached."
	resolver hasPrimary
		ifFalse: [ resolver findPrimaryFor: self ].
	primaryUrl := resolver primaryUrl.
	client := self makeClientWith: primaryUrl.
	client
		ifNil: [ resolver resetRoles.
			ReplicaSetPrimaryNotFound
				signal: 'Primary node could not be reached.' ].

	"2. Primary can be used.
	The client should be able to get an answer from querying the users collection in the admin database."
	[ [ adminDb := MongoDatabase root: client name: 'admin'.
	usersCollection := MongoCollection
		database: adminDb
		name: 'system.users'.
	usersCollection size
	"If it can evaluate the size we know it can receive answers from queries." ]
		on: Error
		do: [ :x | 
			MaplessReadWriteOperationFailed
				signal: 'Primary node could not query the "admin" database' ] ]
		ensure: [ client ifNotNil: [ client close ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			'(R/O: ' , self busyReadOnlyClients size asString , ' busy, R/O: '
				, self idleReadOnlyClients size asString , ' idle, R/W: '
				, self busyReadWriteClients size asString , ' busy, R/W: '
				, self idleReadWriteClients size asString , ' idle)'
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
	^ self currentClientDynamicVariableClass
		value: client
		during: [ [ aBlock value: client ]
				ensure: [ self returnReadOnlyClient: client ] ] ]
		on: NetworkError
		do: [ :x1 | 
			client ifNotNil: [ client reset ].
			self readOnlyError: x1 ] ]
		on: Error
		do: [ :x2 | 
			self triggerEvent: #readOnlyError: with: x2.
			client ifNotNil: [ client reset ].
			x2 pass ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readOnlyError: anExceptionOrNil [
	self triggerEvent: #readOnlyError: with: anExceptionOrNil.
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
	^ self currentClientDynamicVariableClass
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
			self triggerEvent: #readWriteError: with: x3.
			client ifNotNil: [ client reset ].
			x3 pass ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> readWriteError: anExceptionOrNil [
	self triggerEvent: #readWriteError: with: anExceptionOrNil.
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

	readOnlyProtection
		critical: [ self idleReadOnlyClients copy
				do: [ :each | 
					(each isAt: resolver primaryUrl)
						ifTrue: [ 
							self silentlyClose: each.
							self idleReadOnlyClients remove: each ifAbsent: [ nil ] ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeInvalidReadWriteClients [
	"Removes read-write clients that might be opened using other than the current address of the primary."

	readWriteProtection
		critical: [ self idleReadWriteClients copy
				do: [ :each | 
					(each isAt: resolver primaryUrl)
						ifFalse: [ 
							self silentlyClose: each.
							self idleReadWriteClients remove: each ifAbsent: [ nil ] ] ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeReadOnlyClient: aMongoAPI ifAbsent: aBlock [
	self idleReadOnlyClients remove: aMongoAPI ifAbsent: aBlock
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> removeReadWriteClient: aMongoAPI ifAbsent: aBlock [
	self idleReadWriteClients remove: aMongoAPI ifAbsent: aBlock
]

{ #category : #healthcheck }
MaplessMongoReplicaSetPool >> replicaSetAvailabilityHealthcheck [
	"Raise proper exceptions (to be handled) if any of these check fails:
	1. Primary can be reached.
	2. Primary can be used.
	3. There are at least the minimum of configured primary clients.
	4. Secondaries can be reached.
	5. Secondaries can be used.
	6. There are at least the minimum of configured secondary clients per node."

	self ensureTopology.
	self primaryAvailabilityHealthcheck.
	resolver secondaryUrls
		do: [ :mongoUrl | self secondaryAvailabilityHealthcheck: mongoUrl ].
	self ensureClients.
]

{ #category : #healthcheck }
MaplessMongoReplicaSetPool >> replicaSetCongifurationHealthcheck [
	"1. Connect to a secondary node in the replica set.
	2. Verify that the list of nodes in the replica set configuration are the same that my resolver has.
	3. Raise an exception if any inconsistencies are detected, otherwise proceed silently."

	| client membersUrls rsStatus |
	"1. Connect to a node in the replica set."
	resolver mongoUrls
		detect: [ :mongoUrl | 
			client := self makeClientWith: mongoUrl.
			client notNil ]
		ifNone: [ MaplessNoReplicaSetMemberCouldBeReached signal ].
	rsStatus := client replicaSetStatus.

	"2. Verify that the list of nodes in the replica set configuration is the same as the one found."
	membersUrls := rsStatus members collect: [ :e | e name asMongoUrl ].
	((membersUrls includesAll: resolver mongoUrls)
		and: [ resolver mongoUrls includesAll: membersUrls ])
		ifFalse: [ MaplessReplicaSetInconsistentConfiguration
				signal:
					'The nodes informed by the replica set do not match the ones configured in this pool' ].

	"3. Raise an exception if any inconsistencies are detected, otherwise proceed silently."
	
	"All good so far, moving on."				
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> requestReadOnlyClient [
	^ readOnlyProtection
		critical: [ | client |
			self hasPrimary
				ifFalse: [ self findPrimary ].
			client := self hasIdleReadOnlyClients
				ifTrue: [ self getIdleReadOnlyClient ]
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
				ifTrue: [ self getIdleReadWriteClient ]
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

{ #category : #accessing }
MaplessMongoReplicaSetPool >> resolver [
	^ resolver
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> returnReadOnlyClient: aMongoAPI [
	"Sends aMongoAPI to go from the busy ones to the idle ones
	but only if it's still valid and is still connected to a secondary."

	readOnlyProtection
		critical: [ self busyReadOnlyClients remove: aMongoAPI ifAbsent: [ nil ].
			aMongoAPI isValid
				ifTrue: [ self idleReadOnlyClients add: aMongoAPI ] ]
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> returnReadWriteClient: aMongoAPIOrNil [
	"Sends aMongoAPI to go from the busy ones to the idle ones
	but only if it's still valid and is still a connected to the primary."

	aMongoAPIOrNil ifNil: [ ^ self ].
	readWriteProtection
		critical: [ self busyReadWriteClients remove: aMongoAPIOrNil ifAbsent: [ nil ].
			aMongoAPIOrNil isValid
				ifTrue: [ self idleReadWriteClients add: aMongoAPIOrNil ] ]
]

{ #category : #healthcheck }
MaplessMongoReplicaSetPool >> secondaryAvailabilityHealthcheck: aMongoUrl [
	"Raise proper exceptions (to be handled) if any of these check fails:
	1. Secondary can be reached.
	2. Client status is reported as secondary.
	3. Secondary receives a query answer."

	| client adminDb usersCollection |
	"1. Secondary can be reached."
	client := self makeClientWith: aMongoUrl.
	client
		ifNil: [ resolver resetRoles.
			ReplicaSetSecondaryNotFound
				signal: 'Secondary node could not be reached.' ].

	"2. Client status is reported as secondary."
	(client replicaSetStatus secondaryMembers
		noneSatisfy: [ :each | each name asMongoUrl = client asMongoUrl ])
		ifTrue: [ MaplessReplicaSetNodeRoleChanged
				signal:
					('Expected secondary not found in Replica Set: {1}'
						format: {aMongoUrl asString}) ].

	"3. Secondary can be used.
	The client should be able to get an answer from querying the users collection in the admin database."
	[ [ adminDb := MongoDatabase root: client name: 'admin'.
	usersCollection := MongoCollection
		database: adminDb
		name: 'system.users'.
	usersCollection size
	"If it can evaluate the size we know it can receive answers from queries." ]
		on: Error
		do: [ :x | 
			MaplessReadOnlyOperationFailed
				signal: 'Secondary node could not query the "admin" database' ] ]
		ensure: [ client ifNotNil: [ client close ] ].
]

{ #category : #accessing }
MaplessMongoReplicaSetPool >> secondaryUrls [
	^ resolver secondaryUrls
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> silentlyClose: aMongoClient [
	[ aMongoClient close ]
		on: Error
		do: [ :x | "No noise, thanks" ].

]

{ #category : #actions }
MaplessMongoReplicaSetPool >> start [
	self replicaSetCongifurationHealthcheck.
	self findPrimary.
	self startHealthChecker
]

{ #category : #healthcheck }
MaplessMongoReplicaSetPool >> startHealthChecker [
	healthChecker := [ [ [ self triggerEvent: #beforeReplicaSetHealthCheck.
	self healthCheckerInterval seconds asDelay wait.
	self replicaSetAvailabilityHealthcheck.
	self triggerEvent: #afterSetReplicaHealthCheck ]
		on: Error, MaplessError
		do: [ :x | self triggerEvent: #replicaSetHealthCheckError: with: x ] ]
		repeat ]
		forkAt: Processor userBackgroundPriority
		named: 'rs-healthCheck'
]

{ #category : #actions }
MaplessMongoReplicaSetPool >> stop [
	
	self flag: #todo. "Stop for busy clients?"
	
	self idleReadOnlyClients do: [ :each | each close ].
	self idleReadWriteClients do: [ :each | each close ].
	
	self stopHealthChecker
]

{ #category : #healthcheck }
MaplessMongoReplicaSetPool >> stopHealthChecker [
	healthChecker
		ifNotNil: [ | released |
			released := healthChecker.
			healthChecker := nil.
			released terminate ]
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
