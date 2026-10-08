Extension { #name : #Object }

{ #category : #'*Mapless-Base' }
Object >> asJSONString [
	^ String streamContents: [ :str | self jsonWriteOn: str ]
]

{ #category : #'*Mapless-Base' }
Object >> unreferenced [
	^ self
]
