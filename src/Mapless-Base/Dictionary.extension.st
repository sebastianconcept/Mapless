Extension { #name : #Dictionary }

{ #category : #'*Mapless-Base' }
Dictionary >> asJsonObjectIn: aMaplessRepository [
	"Answers a JSON object based on the contents of this dictionary."

	^ [ :json | 
	self
		keysAndValuesDo: [ :key :value | 
			value isDictionary
				ifFalse: [ (aMaplessRepository canRepresentArrayOfMaplessReferences: value)
						ifTrue: [ json
								at: key
								put: (value collect: [ :each | each asJsonObjectIn: aMaplessRepository ]) ]
						ifFalse: [ json at: key put: value ] ]
				ifTrue: [ json at: key put: (value asJsonObjectIn: aMaplessRepository) ] ].
	json ] value: JsonObject new
]
