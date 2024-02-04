"
I provide Redis clients for storage and channel messaging
"
Class {
	#name : #MaplessRedisPool,
	#superclass : #MaplessAbstractPool,
	#instVars : [
		'redis',
		'subscribers',
		'publishers'
	],
	#category : #'Mapless-Redis-Core'
}

{ #category : #'instance creation' }
MaplessRedisPool class >> local [

	^ self targetUrl: 'sync://localhost'
]

{ #category : #'instance creation' }
MaplessRedisPool class >> targetUrl: anUrl [

	| rediStick |
	rediStick := RsRediStick targetUrl: anUrl.
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

{ #category : #initialization }
MaplessRedisPool >> initialize [

	super initialize.

	subscribers := Dictionary new.
	publishers := Dictionary new
]

{ #category : #actions }
MaplessRedisPool >> newClient [

	^ RsRediStick targetUrl: redis stick targetUrl
]

{ #category : #actions }
MaplessRedisPool >> publish: aChannelName message: anEventSelector [

	| publisher c |
	publisher := publishers at: aChannelName ifAbsentPut: [ 
		             c := self newClient.
		             c connect.
		             c endpoint enterPubsub.
		             c ].

	publisher endpoint
		publish: aChannelName
		message: (STON toString: anEventSelector)
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
	^ redis endpoint select: aZeroBasedDbIndex
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
MaplessRedisPool >> subscribe: aChannelName callback: anAction [

	"Subscribes the provided action, anAction, to the specified channel 
	identified by aChannelName. 
	If there is no client for aChannelName, a new client is created for it. 

	Example:
		pool subscribe: 'updates' callback: [ :message | self handleUpdateMessage: message ]"

	| subscriber |
	subscriber := subscribers
		              at: aChannelName
		              ifAbsentPut: [ self newClient connect ].

	subscriber endpoint subscribe: { aChannelName } callback: anAction
]

{ #category : #actions }
MaplessRedisPool >> unsubscribe: aChannelName [

	| subscriber |
	subscriber := subscribers at: aChannelName ifAbsent: [ ^ self ].

	subscriber endpoint unsubscribe: { aChannelName }
]
