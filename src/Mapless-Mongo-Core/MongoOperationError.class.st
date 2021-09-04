Class {
	#name : #MongoOperationError,
	#superclass : #Error,
	#instVars : [
		'reply'
	],
	#category : #'Mapless-Mongo-Core-Errors'
}

{ #category : #'instance creation' }
MongoOperationError class >> newFor: aReply [
	^ self basicNew
		initialize: aReply;
		yourself
]

{ #category : #signalling }
MongoOperationError class >> signalFor: reply message: aString [
	^ (self newFor: reply) signal: aString
]

{ #category : #initialization }
MongoOperationError >> initialize: aReply [
	self initialize.
	reply := aReply
]

{ #category : #accessing }
MongoOperationError >> reply [
	^ reply
]
