"
I model a Redis PUBSUB messages in a way that is convenient for Mapless in an Observer Pattern
"
Class {
	#name : #MaplessRedisPubsubMessage,
	#superclass : #Object,
	#instVars : [
		'payload'
	],
	#category : #'Mapless-Redis-Observer'
}

{ #category : #'instance creation' }
MaplessRedisPubsubMessage class >> fromPubsubResponse: pubsubResponseString [

	| payload |
	payload := pubsubResponseString payload ifNil: [ nil ] ifNotNil: [ 
		           STON fromString:
			           (self normalizedResponse: pubsubResponseString payload) ].

	^ self new initializeOn: payload
]

{ #category : #accessing }
MaplessRedisPubsubMessage class >> normalizedResponse: pubsubResponseString [

	"Redis would respond with strings that have single quotes escaped using \
	so here we normalize that for Smalltalk."

	^ (pubsubResponseString copyReplaceAll: '\''' with: '''') allButFirst
		  allButLast
]

{ #category : #operating }
MaplessRedisPubsubMessage >> execute: anAction on: aMapless [

	| selector |
	payload ifNil: [ ^ self ].
	"Get the selector (or fail accordingly)"
	selector := payload at: #s ifAbsent: [ 
		            MaplessMalformedPubsubMessage signal:
			            'Pubsub payload missing selector' ].
	(selector isKeyword or: [ selector isBinary ]) ifTrue: [ 
		MaplessMalformedPubsubMessage signal:
			'Pubsub payload missing selector' ].
	^ anAction value
]

{ #category : #initialization }
MaplessRedisPubsubMessage >> initializeOn: anObject [

	payload := anObject
]

{ #category : #operating }
MaplessRedisPubsubMessage >> withArgumentsExecute: aMessageSelector on: anObject [

	| selector arguments |
	payload ifNil: [ ^ self ].

	"Get the selector (or fail accordingly)"
	selector := payload at: #s ifAbsent: [ 
		            MaplessMalformedPubsubMessage signal:
			            'Pubsub payload missing selector' ].
	aMessageSelector isUnary ifTrue: [ 
		MaplessMalformedPubsubMessage signal:
			'Only binary or keyword selectors are expected' ].

	"Get its arguments if any"
	arguments := payload at: #a ifAbsent: [ 
		             MaplessMalformedPubsubMessage signal:
			             'Pubsub payload missing selector' ].
	^ anObject perform: aMessageSelector withArguments: arguments
]
