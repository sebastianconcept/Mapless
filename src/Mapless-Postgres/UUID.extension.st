Extension { #name : #UUID }

{ #category : #'*Mapless-Postgres' }
UUID >> jsonWriteOn: aStream [

	"Pharo 13 UUID is no longer a ByteArray, so it doesn't inherit the
	Collection implementation. Writes the same JSON (an array of bytes)
	that Pharo 12 and older produced to keep persisted data compatible."

	(self class inheritsFrom: Collection) ifTrue: [ 
		^ super jsonWriteOn: aStream ].
	self uuidData jsonWriteOn: aStream
]
