Class {
	#name : #MaplessMongoError,
	#superclass : #MaplessError,
	#instVars : [
		'mongoCommandError'
	],
	#category : #'Mapless-Mongo-Core-Errors'
}

{ #category : #'instance creation' }
MaplessMongoError class >> onMongoCommandError: aMongoCommandError [
	^ self new
		mongoCommandError: aMongoCommandError;
		yourself
]

{ #category : #'instance creation' }
MaplessMongoError class >> signalWith: aMongoCommandError [
	(self onMongoCommandError: aMongoCommandError) signal
]

{ #category : #accessing }
MaplessMongoError >> code [
	^ mongoCommandError
		ifNotNil: [ mongoCommandError code ]
		ifNil: [ nil ]
]

{ #category : #accessing }
MaplessMongoError >> messageText [
	^ mongoCommandError
		ifNotNil: [ mongoCommandError messageText ]
		ifNil: [ super messageText ]
]

{ #category : #accessing }
MaplessMongoError >> mongoCommandError [
	^ mongoCommandError
]

{ #category : #accessing }
MaplessMongoError >> mongoCommandError: anObject [
	mongoCommandError := anObject
]
