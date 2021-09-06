Extension { #name : #Object }

{ #category : #'*Mapless-Base-Core' }
Object >> asJSONString [
	^ String streamContents: [ :str | self jsonWriteOn: str ]
]

{ #category : #'*Mapless-Base-Core' }
Object >> unreferenced [
	^ self
]
