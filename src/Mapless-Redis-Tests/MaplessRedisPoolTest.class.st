Class {
	#name : #MaplessRedisPoolTest,
	#superclass : #MaplessTestCase,
	#category : #'Mapless-Redis-Tests'
}

{ #category : #tests }
MaplessRedisPoolTest >> testNewClient [

	| pool |
	pool := MaplessRedisPool local.

	self assert: pool notNil.
	self assert: pool redis notNil.
	self assert: pool redis stick notNil.
	self assert: pool redis stick targetUrl notNil.
	self assert: pool redis stick targetUrl equals: 'sync://localhost'.

	pool := MaplessRedisPool targetUrl: 'sync://127.0.0.1'.
	self assert: pool redis stick targetUrl equals: 'sync://127.0.0.1'
]

{ #category : #tests }
MaplessRedisPoolTest >> testSubscribe [

	| pool valued reaction |
	pool := MaplessRedisPool local.
	valued := false.
	reaction := [ :msg | msg payload ifNotNil: [ valued := true ] ].
	self
		shouldnt: [ pool subscribe: #testing callback: reaction ]
		raise: Error.
	self deny: valued.
	pool publish: #testing message: 'answer'.
	120 milliSeconds asDelay wait.
	self assert: valued
]

{ #category : #tests }
MaplessRedisPoolTest >> testUnsubscribe [

	| pool valued reaction |
	pool := MaplessRedisPool local.
	valued := false.
	reaction := [ :msg | msg payload ifNotNil: [ valued := true ] ].
	self
		shouldnt: [ pool subscribe: #testing callback: reaction ]
		raise: Error.
	self deny: valued.
	pool publish: #testing message: 'answer'.
	30 milliSeconds asDelay wait.
	self assert: valued.
	valued := false.

	pool unsubscribe: #testing.
	pool publish: #testing message: 'answer'.
	30 milliSeconds asDelay wait.
	self deny: valued.
	
]
