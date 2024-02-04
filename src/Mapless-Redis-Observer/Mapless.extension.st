Extension { #name : #Mapless }

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubTriggerEvent: anEventSelector [

	self class getPubsubRepository publish: anEventSelector from: self
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubTriggerEvent: anEventSelector with: anObject [

	^ self
		  pubsubTriggerEvent: anEventSelector
		  withArguments: { anObject }
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubTriggerEvent: anEventSelector withArguments: anArgumentList [

	self class getPubsubRepository
		publish: anEventSelector
		from: self
		arguments: anArgumentList
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubUnsubscribe: anEventSelector [

	self class getPubsubRepository
		unsubscribe: self
		from: anEventSelector
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubWhen: anEventSelector evaluate: anAction [

	self class getPubsubRepository
		subscribe: self
		when: anEventSelector
		evaluate: anAction
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubWhen: anEventSelector send: aMessageSelector to: anObject [

	self
		pubsubWhen: anEventSelector
		evaluate:
		(WeakMessageSend receiver: anObject selector: aMessageSelector)
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubWhen: anEventSelector send: aMessageSelector to: anObject with: anArg [

	self pubsubWhen: anEventSelector evaluate: (WeakMessageSend
			 receiver: anObject
			 selector: aMessageSelector
			 argument: anArg)
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubWhen: anEventSelector send: aMessageSelector to: anObject withArguments: anArgArray [

	self pubsubWhen: anEventSelector evaluate: (WeakMessageSend
			 receiver: anObject
			 selector: aMessageSelector
			 arguments: anArgArray)
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubWithRemoteArgumentWhen: anEventSelector send: aMessageSelector to: anObject [

	self class getPubsubRepository
		withRemoteArgumentSubscribe: self
		when: anEventSelector
		send: aMessageSelector
		to: anObject
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> pubsubWithRemoteArgumentsWhen: anEventSelector send: aMessageSelector to: anObject [

	self class getPubsubRepository
		withRemoteArgumentsSubscribe: self
		when: anEventSelector
		send: aMessageSelector
		to: anObject
]
