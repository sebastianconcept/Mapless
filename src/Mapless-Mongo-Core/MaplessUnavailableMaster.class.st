Class {
	#name : #MaplessUnavailableMaster,
	#superclass : #MaplessMongoError,
	#category : #'Mapless-Mongo-Core-Errors'
}

{ #category : #accessing }
MaplessUnavailableMaster >> defaultAction [
	"accessing"

	UnhandledError signalForException: self
]
