Extension { #name : #NeoJSONWriter }

{ #category : #'*Mapless-Mongo-Log' }
NeoJSONWriter >> writeDateAndTime: aDateAndTime [
	"It's not really JSON but is something that MongoDB accepts injected in it."

	writeStream
		nextPutAll: ('ISODate("{1}")' format: {aDateAndTime asString})
]

{ #category : #'*Mapless-Mongo-Log' }
NeoJSONWriter >> writeOID: anOID [
	"It's not really JSON but is something that MongoDB accepts injected in it."

	writeStream
		nextPutAll:
			('ObjectId("{1}")'
				format: {(anOID value hex allButFirst: 3) asLowercase})
]
