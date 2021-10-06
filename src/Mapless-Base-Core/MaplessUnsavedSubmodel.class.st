Class {
	#name : #MaplessUnsavedSubmodel,
	#superclass : #MaplessError,
	#category : #'Mapless-Base-Core-Errors'
}

{ #category : #accessing }
MaplessUnsavedSubmodel >> defaultAction [
	"accessing"

	UnhandledError signalForException: self
]
