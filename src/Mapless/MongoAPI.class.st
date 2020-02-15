Class {
	#name : #MongoAPI,
	#superclass : #Mongo,
	#category : #'Mapless-Mongo'
}

{ #category : #testing }
MongoAPI >> isValid [
	^ self isAvailable 
]

{ #category : #actions }
MongoAPI >> reset [
	"Close, no fail"

	[ self close ]
		on: Error
		do: [ :x |  ]
]
