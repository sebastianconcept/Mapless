Class {
	#name : #MaplessReplicaSetMongoPoolTest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Mongo-Tests-Tests'
}

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
