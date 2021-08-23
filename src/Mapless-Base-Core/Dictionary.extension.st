Extension { #name : #Dictionary }

{ #category : #'*Mapless-Base-Core' }
Dictionary >> asJsonObject [
	"Answers a JSON object based on the contents of this dictionary."

	^ [ :json | 
	self
		keysAndValuesDo: [ :key :value | 
			value isDictionary
				ifFalse: [ (Mapless canRepresentArrayOfMaplessReferences: value)
						ifTrue: [ json at: key put: (value collect: [ :each | each asJsonObject ]) ]
						ifFalse: [ json at: key put: value ] ]
				ifTrue: [ json at: key put: value asJsonObject ] ].
	json ] value: JsonObject new
]
