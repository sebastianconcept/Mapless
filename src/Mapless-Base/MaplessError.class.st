"
I'm the type of Error specific to Mapless scenarios
"
Class {
	#name : #MaplessError,
	#superclass : #Error,
	#category : #'Mapless-Base-Errors'
}

{ #category : #accessing }
MaplessError >> defaultAction [
	UnhandledError signalForException: self
]
