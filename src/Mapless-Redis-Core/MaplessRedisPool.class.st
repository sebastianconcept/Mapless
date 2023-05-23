Class {
	#name : #MaplessRedisPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'redis'
	],
	#category : #'Mapless-Redis-Core-Connections'
}

{ #category : #'instance creation' }
MaplessRedisPool class >> local [
	| rediStick |
	rediStick := RsRediStick targetUrl: 'sync://localhost'.
	rediStick connect.
	^ self new
		redis: (RsRedis on: rediStick);
		yourself
]

{ #category : #'redis-commands' }
MaplessRedisPool >> auth: aString [
	^ redis endpoint auth: aString
]

{ #category : #'redis-commands' }
MaplessRedisPool >> drop [
	"Delete all keys of the currently selected Redis database"

	^ redis endpoint flushDb
]

{ #category : #'redis-commands' }
MaplessRedisPool >> info [
	^ redis endpoint info
]

{ #category : #accessing }
MaplessRedisPool >> redis [
	^ redis
]

{ #category : #accessing }
MaplessRedisPool >> redis: anObject [
	redis := anObject
]

{ #category : #'redis-commands' }
MaplessRedisPool >> setDatabase: aZeroBasedDbIndex [
	^ self
		withClientDo: [ :client | client endpoint select: aZeroBasedDbIndex ]
]

{ #category : #actions }
MaplessRedisPool >> start [
	^ self start: 1
]

{ #category : #actions }
MaplessRedisPool >> start: anInteger [
	^ redis stick connect
]

{ #category : #actions }
MaplessRedisPool >> stop [
	^ redis stick close
]

{ #category : #actions }
MaplessRedisPool >> withClientDo: aBlock [
	^ aBlock value: redis
]
