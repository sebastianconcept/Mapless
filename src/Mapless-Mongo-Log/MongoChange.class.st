"
I represent an insert, delete or update in mapless collections (other than mine)
"
Class {
	#name : #MongoChange,
	#superclass : #Mapless,
	#category : #'Mapless-Mongo-Log-Core'
}

{ #category : #printing }
MongoChange >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll:
			('(sequenceNumber: {1} type: {2} collection: {3})'
				format:
					{self sequenceNumber asString.
					self type.
					self collectionName})
]
