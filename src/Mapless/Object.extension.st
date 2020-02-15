Extension { #name : #Object }

{ #category : #'*Mapless' }
Object >> asJSONString [

	^ String streamContents: [:str |
		self jsonWriteOn: str ]
]

{ #category : #'*Mapless' }
Object >> unreferenced [

	^ self
]
