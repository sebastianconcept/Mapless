"
I'm a thread-safe pool of Redis clients that doesn't block.
"
Class {
	#name : #MaplessBlocklessRedisPool,
	#superclass : #MaplessBlocklessPool,
	#instVars : [
		'targetUrl',
		'redis',
		'databaseIndex'
	],
	#category : #'Mapless-Redis-Core-Connections'
}

{ #category : #accessing }
MaplessBlocklessRedisPool class >> local [
	^ self on: 'sync://localhost' 
]

{ #category : #'instance creation' }
MaplessBlocklessRedisPool class >> on: anURL [
	^ self new
		targetUrl: anURL;
		yourself
]

{ #category : #accessing }
MaplessBlocklessRedisPool class >> targetUrl: aString [
	^ self new
		targetUrl: aString;
		yourself
]

{ #category : #commands }
MaplessBlocklessRedisPool >> auth: aString [
	^ self withClientDo: [ :client | client endpoint auth: aString ]
]

{ #category : #actions }
MaplessBlocklessRedisPool >> closeClient: aClient [
	aClient endpoint close
]

{ #category : #actions }
MaplessBlocklessRedisPool >> currentClientDynamicVariable [
	"Answers the class of the dynamic variable that will
	hold the value of the current client during the evaluation of its usage."

	^ RedisCurrentClient
]

{ #category : #accessing }
MaplessBlocklessRedisPool >> databaseIndex [
	^ databaseIndex
]

{ #category : #accessing }
MaplessBlocklessRedisPool >> databaseIndex: anInteger [
	databaseIndex := anInteger
]

{ #category : #testing }
MaplessBlocklessRedisPool >> isClientConnected: aClient [
	"Answers true if the resource is actually active."

	^ aClient endpoint isConnected
]

{ #category : #actions }
MaplessBlocklessRedisPool >> makeClient [
	"Returns a new client so it can be (re)used in the pool"

	| newRedisClient |
	newRedisClient := RsRediStick targetUrl: targetUrl.
	newRedisClient connect.
	newRedisClient endpoint auth: password.
	^ RsRedis on: newRedisClient
]

{ #category : #commands }
MaplessBlocklessRedisPool >> setDatabase: aZeroBasedDbIndex [
	^ self
		withClientDo: [ :client | client endpoint select: aZeroBasedDbIndex ]
]

{ #category : #accessing }
MaplessBlocklessRedisPool >> targetUrl [
	^ targetUrl
]

{ #category : #accessing }
MaplessBlocklessRedisPool >> targetUrl: anObject [
	targetUrl := anObject
]
