Class {
	#name : #MaplessReplicaSetMongoPoolTest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Mongo-ReplicaSet-Tests'
}

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testCountClientsFromUrl [

	| pool |
	pool := MaplessMongoReplicaSetPool
		        mongoUrls: { '1@localhost:27017' }
		        database: 'Mapless-Test'.

	pool idleReadOnlyClients add:
		(pool makeClientWith: '1@localhost:27017').

	self
		assert: (pool countClientsTo: 'localhost:27017' asMongoUrl)
		equals: 1
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testDefaults [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        fromString: '1@localhost:27017'
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.
	self
		assert: repository accessor minReadWriteClients
		equals: MaplessMongoReplicaSetPool defaultMinReadWriteClients.
	self
		assert: repository accessor maxReadWriteClients
		equals: MaplessMongoReplicaSetPool defaultMaxReadWriteClients.
	self
		assert: repository accessor minReadOnlyClients
		equals: MaplessMongoReplicaSetPool defaultMinReadOnlyClients.
	self
		assert: repository accessor maxReadOnlyClients
		equals: MaplessMongoReplicaSetPool defaultMaxReadOnlyClients
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testDeleteConcern [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        fromString: '1@localhost:27017'
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.

	self deny: repository defaultDeleteConcern notNil.
	repository defaultDeleteConcern: #majority.

	self assert: repository defaultDeleteConcern equals: #majority
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testDynamicVariable [

	self
		assert:
		MaplessMongoReplicaSetPool local currentClientDynamicVariableClass
		equals: MongoCurrentClient
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testGetIdleReadOnlyClient [

	| pool |
	pool := MaplessMongoReplicaSetPool
		        mongoUrls: { '1@localhost:27017' }
		        database: 'Mapless-Test'.

	pool idleReadOnlyClients add:
		(pool makeClientWith: '1@localhost:27017').

	self assert: pool getIdleReadOnlyClient class equals: MongoAPI
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testGetIdleReadWriteClient [

	| pool |
	pool := MaplessMongoReplicaSetPool
		        mongoUrls: { '1@localhost:27017' }
		        database: 'Mapless-Test'.

	pool idleReadWriteClients add:
		(pool makeClientWith: '1@localhost:27017').

	self assert: pool getIdleReadWriteClient class equals: MongoAPI
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testHasBusyClients [

	| pool |
	pool := MaplessMongoReplicaSetPool
		        mongoUrls: { '1@localhost:27017' }
		        database: 'Mapless-Test'.

	pool busyReadOnlyClients add:
		(pool makeClientWith: '1@localhost:27017').

	self assert: pool hasBusyClients.
	pool busyReadOnlyClients removeAll.

	pool busyReadWriteClients add:
		(pool makeClientWith: '1@localhost:27017').

	self assert: pool hasBusyClients
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testHasHealthChecker [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        fromString: '1@localhost:27017'
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.

	self assert: repository accessor hasHealthChecker
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testHasIdleClients [

	| pool |
	pool := MaplessMongoReplicaSetPool
		        mongoUrls: { '1@localhost:27017' }
		        database: 'Mapless-Test'.

	pool idleReadOnlyClients add:
		(pool makeClientWith: '1@localhost:27017').

	self assert: pool hasIdleReadOnlyClients.
	pool idleReadOnlyClients removeAll.

	pool idleReadWriteClients add:
		(pool makeClientWith: '1@localhost:27017').

	self assert: pool hasIdleReadWriteClients
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testInitializeIsPrimary [

	| api result |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ result := api isPrimary ] raise: Error.
	self deny: result.
	api close
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testInsertConcern [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        fromString: '1@localhost:27017'
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.

	self deny: repository defaultInsertConcern notNil.
	repository defaultInsertConcern: #majority.

	self assert: repository defaultInsertConcern equals: #majority
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testInstanceCreationFromMongoUrls [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        mongoUrls: { '1@localhost:27017' }
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.

	self
		assert: repository accessor resolver mongoUrls first
		equals: '1@localhost:27017' asMongoUrl
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testIsPrimary [

	| api result |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self
		shouldnt: [ result := api admin isMaster isPrimary ]
		raise: Error.
	self deny: result.
	api close
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testIsReadOnly [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.
	self assert: api isReadOnly.
	api close
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testIsReadWrite [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.
	self deny: api isReadWrite.
	api close
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testIsType [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.

	self assert: (api isType: #readOnly).
	api close
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testReadConcern [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        fromString: '1@localhost:27017'
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.

	self deny: repository defaultReadConcern notNil.
	repository defaultReadConcern: #majority.

	self assert: repository defaultReadConcern equals: #majority
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testResetRole [

	| api |
	api := MongoAPI mongoUrl: 'mongodb://localhost:27017/Mapless-Test'.
	api open.

	self shouldnt: [ api isPrimary ] raise: Error.

	self assert: (api isType: #readOnly).

	self shouldnt: [ api resetIsPrimary ] raise: Error.
	self shouldnt: [ api isPrimary ] raise: Error.
	self assert: (api isType: #readOnly).
	api close
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testUpdateConcern [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        fromString: '1@localhost:27017'
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.

	self deny: repository defaultUpdateConcern notNil.
	repository defaultUpdateConcern: #majority.

	self assert: repository defaultUpdateConcern equals: #majority
]

{ #category : #tests }
MaplessReplicaSetMongoPoolTest >> testUpsertConcern [

	| pool repository |
	pool := MaplessMongoReplicaSetPool
		        fromString: '1@localhost:27017'
		        database: 'Mapless-Test'.

	repository := MaplessMongoRepository for: 'Mapless-Test' with: pool.

	self deny: repository defaultUpsertConcern notNil.
	repository defaultUpsertConcern: #majority.

	self assert: repository defaultUpsertConcern equals: #majority
]
