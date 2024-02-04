Extension { #name : #MaplessRedisRepository }

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> channelNameFor: aMapless when: anEventSelector [

	"Answers the channel name to use for messaging occurrences 
	of anEventSelector about the given mapless object, aMapless.
	The channel name is formatted as '{1}:{2}', where:
	- {1} is the id of the mapless object, aMapless.
	- {2} is the string representation of anEventSelector."

	^ '{1}:{2}' format: { 
			  aMapless id asString.
			  anEventSelector asString }
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> publish: anEventSelector from: aMapless [

	(self isUnsaved: aMapless) ifTrue: [ 
		MaplessObserverOnUnsaved signal:
			'Mapless objects need to be saved for publishing events.' ].

	accessor
		publish: (self channelNameFor: aMapless when: anEventSelector)
		message: (self pubsubPayloadFor: anEventSelector)
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> publish: anEventSelector from: aMapless arguments: someArguments [

	(self isUnsaved: aMapless) ifTrue: [ 
		MaplessObserverOnUnsaved signal:
			'Mapless objects need to be saved for publishing events.' ].

	accessor
		publish: (self channelNameFor: aMapless when: anEventSelector)
		message:
		(self pubsubPayloadFor: anEventSelector arguments: someArguments)
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> pubsubPayloadFor: anEventSelector [

	"Answers a new pubsub payload for anEventSelector with no arguments."

	^ STON toString: { (#s -> anEventSelector) } asDictionary
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> pubsubPayloadFor: anEventSelector arguments: someArguments [

	"Answers a new pubsub payload for anEventSelector with someArguments."

	^ STON toString: { 
			  (#s -> anEventSelector).
			  (#a -> someArguments) } asDictionary
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> subscribe: aMapless when: anEventSelector evaluate: anAction [

	"Subscribes anAction to be evaluated whenever 
	anEventSelector is published in aMapless.

	Example:
		maplessRedisRepository 
			subscribe: someMaplessObject 
			when: #updated 
			evaluate: [ :event | self handleUpdateEvent: event ]"

	"Verify only saved Mapless subscribe to pubsub channels"
	(self isUnsaved: aMapless) ifTrue: [ 
		MaplessObserverOnUnsaved signal:
			'Cannot observe an unsaved mapless object' ].

	"Subscribe to the right channel for anEventSelector"
	accessor
		subscribe: (self channelNameFor: aMapless when: anEventSelector)
		callback: [ :pubsubResponse | 
			| message |
			message := MaplessRedisPubsubMessage fromPubsubResponse:
				           pubsubResponse.
			message execute: anAction on: aMapless ]
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> unsubscribe: aMapless from: anEventSelector [

	"Unsubscribe from the right channel for anEventSelector on aMapless"

	accessor unsubscribe:
		(self channelNameFor: aMapless when: anEventSelector)
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> withRemoteArgumentSubscribe: aMapless when: anEventSelector send: aMessageSelector to: anObject [

	"Whenever anEventSelector is published in aMapless,
	anObject gets subscribed to perform aMessageSelector 
	with the remotely received arguments."

	^ self
		  withRemoteArgumentsSubscribe: aMapless
		  when: anEventSelector
		  send: aMessageSelector
		  to: anObject
]

{ #category : #'*Mapless-Redis-Observer' }
MaplessRedisRepository >> withRemoteArgumentsSubscribe: aMapless when: anEventSelector send: aMessageSelector to: anObject [

	"Whenever anEventSelector is published in aMapless,
	anObject gets subscribed to perform aMessageSelector 
	with the remotely received arguments."

	"Verify only saved Mapless subscribe to pubsub channels"

	(self isUnsaved: aMapless) ifTrue: [ 
		MaplessObserverOnUnsaved signal:
			'Cannot observe an unsaved mapless object' ].

	"Subscribe to the right channel for anEventSelector"
	accessor
		subscribe: (self channelNameFor: aMapless when: anEventSelector)
		callback: [ :pubsubResponse | 
			| message |
			message := MaplessRedisPubsubMessage fromPubsubResponse:
				           pubsubResponse.
			message withArgumentsExecute: aMessageSelector on: anObject ]
]
