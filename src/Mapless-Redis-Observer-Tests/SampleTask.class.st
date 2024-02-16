"
I can help to test features
"
Class {
	#name : #SampleTask,
	#superclass : #Mapless,
	#category : #'Mapless-Redis-Observer-Tests'
}

{ #category : #accessing }
SampleTask class >> getPubsubRepository [

	^ MaplessRedisHelper repository
]
