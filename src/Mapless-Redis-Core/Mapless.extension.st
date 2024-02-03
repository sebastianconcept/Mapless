Extension { #name : #Mapless }

{ #category : #'*Mapless-Redis-Core' }
Mapless class >> getPubsubRepository [

	"Answer the MaplessRedisRepository that has clients in subscribed state.
	For details on why see:
	https://github.com/mumez/RediStick/issues/30#issuecomment-1921325275
	https://redis.io/commands/subscribe/"

	self subclassResponsibility
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubTriggerEvent: anEventSelector [

	self class getPubsubRepository publish: anEventSelector from: self
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubTriggerEvent: anEventSelector with: anObject [

	^ self
		  pubsubTriggerEvent: anEventSelector
		  withArguments: { anObject }
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubTriggerEvent: anEventSelector withArguments: anArgumentList [

	self class getPubsubRepository
		publish: anEventSelector
		from: self
		arguments: (STON toString: anArgumentList)
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubUnsubscribe: anEventSelector [

	self class getPubsubRepository
		unsubscribe: self
		from: anEventSelector
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubWhen: anEventSelector evaluate: anAction [

	self class getPubsubRepository
		subscribe: self
		when: anEventSelector
		evaluate: anAction
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubWhen: anEventSelector send: aMessageSelector to: anObject [

	self
		pubsubWhen: anEventSelector
		evaluate:
		(WeakMessageSend receiver: anObject selector: aMessageSelector)
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubWhen: anEventSelector send: aMessageSelector to: anObject with: anArg [

	self pubsubWhen: anEventSelector evaluate: (WeakMessageSend
			 receiver: anObject
			 selector: aMessageSelector
			 argument: anArg)
]

{ #category : #'*Mapless-Redis-Core' }
Mapless >> pubsubWhen: anEventSelector send: aMessageSelector to: anObject withArguments: anArgArray [

	self pubsubWhen: anEventSelector evaluate: (WeakMessageSend
			 receiver: anObject
			 selector: aMessageSelector
			 arguments: anArgArray)
]
