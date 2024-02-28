Class {
	#name : #MaplessStandaloneMongoPoolTest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Mongo-Tests-Tests'
}

{ #category : #tests }
MaplessStandaloneMongoPoolTest >> testAuth [

	| pool |
	pool := MaplessStandaloneMongoPool local
		        username: 'tester';
		        password: '123'.

	self
		should: [
		pool withClientDo: [ :client | pool authenticate: client ] ]
		raise: MaplessMongoAuthorizationError
]

{ #category : #tests }
MaplessStandaloneMongoPoolTest >> testHasClients [

	| pool |
	pool := MaplessStandaloneMongoPool local.

	self deny: pool hasClients
]

{ #category : #tests }
MaplessStandaloneMongoPoolTest >> testMakeMinClients [

	| pool |
	pool := MaplessStandaloneMongoPool local.

	self
		deny: pool idleClients size
		equals: MaplessStandaloneMongoPool defaultMinClients.
	pool start.

	self
		assert: pool idleClients size
		equals: MaplessStandaloneMongoPool defaultMinClients
]

{ #category : #tests }
MaplessStandaloneMongoPoolTest >> testMaxClients [

	| pool |
	pool := MaplessStandaloneMongoPool local.

	self
		assert: pool maxClients
		equals: MaplessStandaloneMongoPool defaultMaxClients
]

{ #category : #tests }
MaplessStandaloneMongoPoolTest >> testMinClients [

	| pool |
	pool := MaplessStandaloneMongoPool local.

	self
		assert: pool minClients
		equals: MaplessStandaloneMongoPool defaultMinClients
]

{ #category : #tests }
MaplessStandaloneMongoPoolTest >> testPurgeUnavailable [

	| pool |
	pool := MaplessStandaloneMongoPool local.

	self deny: pool idleClients size equals: 1.
	self assert: pool idleClients size equals: 0.

	pool withClientDo: [ :client |  ].
	self assert: pool idleClients size equals: 1.

	pool withClientDo: [ :client |
		client close.
		self deny: client isValid ].

	pool purgeUnavailable.
	self deny: pool idleClients size equals: 1.
	self deny: pool hasClients.
	self assert: pool idleClients size equals: 0
]

{ #category : #tests }
MaplessStandaloneMongoPoolTest >> testReset [

	| pool |
	pool := MaplessStandaloneMongoPool local.

	self deny: pool idleClients size equals: 1.

	pool withClientDo: [ :client |  ].

	self assert: pool idleClients size equals: 1.
	pool reset.
	self deny: pool idleClients size equals: 1
]
