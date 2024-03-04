Extension { #name : #OrderedJsonObject }

{ #category : #'*Mapless-Base' }
OrderedJsonObject >> asJsonObjectIn: aMaplessRepository [
	^ self
]

{ #category : #'*Mapless-Base' }
OrderedJsonObject >> mpWriteSelector [
	self class == OrderedJsonObject
		ifTrue: [ ^ #writeMap: ].
	^ nil
]
