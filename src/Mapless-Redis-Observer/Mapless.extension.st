Extension { #name : #Mapless }

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> publish: anEventSelector [

	self class getPubsubRepository publish: anEventSelector from: self
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> publish: anEventSelector evaluate: anAction [

	self class getPubsubRepository
		subscribe: self
		when: anEventSelector
		evaluate: anAction
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> publish: anEventSelector send: aMessageSelector to: anObject [

	self
		publish: anEventSelector
		evaluate:
		(WeakMessageSend receiver: anObject selector: aMessageSelector)
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> publish: anEventSelector with: anObject [

	^ self
		  publish: anEventSelector
		  withArguments: { anObject }
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> publish: anEventSelector withArguments: anArgumentList [

	self class getPubsubRepository
		publish: anEventSelector
		from: self
		arguments: anArgumentList
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> subscribe: anEventSelector send: aMessageSelector to: anObject [

	self class getPubsubRepository
		subscribe: self
		when: anEventSelector
		send: aMessageSelector
		to: anObject
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> subscribe: anEventSelector send: aMessageSelector to: anObject with: anArg [

	self publish: anEventSelector evaluate: (WeakMessageSend
			 receiver: anObject
			 selector: aMessageSelector
			 argument: anArg)
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> subscribe: anEventSelector send: aMessageSelector to: anObject withArguments: anArgArray [

	self publish: anEventSelector evaluate: (WeakMessageSend
			 receiver: anObject
			 selector: aMessageSelector
			 arguments: anArgArray)
]

{ #category : #'*Mapless-Redis-Observer' }
Mapless >> unsubscribe: anEventSelector [

	self class getPubsubRepository
		unsubscribe: self
		from: anEventSelector
]
