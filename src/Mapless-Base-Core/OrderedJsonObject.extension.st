Extension { #name : #OrderedJsonObject }

{ #category : #'*Mapless-Base-Core' }
OrderedJsonObject >> asJsonObjectIn: aMaplessRepository [
	^ self
]

{ #category : #'*Mapless-Base-Core' }
OrderedJsonObject >> mpWriteSelector [
	self class == OrderedJsonObject
		ifTrue: [ ^ #writeMap: ].
	^ nil
]
