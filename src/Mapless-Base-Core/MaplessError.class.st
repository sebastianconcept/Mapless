Class {
	#name : #MaplessError,
	#superclass : #Exception,
	#category : #'Mapless-Base-Core-Errors'
}

{ #category : #accessing }
MaplessError >> defaultAction [
	UnhandledError signalForException: self
]
