"
I use 1 document to increment atomically a sequenceNumber so we have MongoChage proper order.
"
Class {
	#name : #MongoChangeSequence,
	#superclass : #Mapless,
	#category : #'Mapless-Mongo-Log-Core'
}

{ #category : #printing }
MongoChangeSequence >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ('({1})' format: {self last asString})
]
