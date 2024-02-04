"
I'm a helper class to access a MaplessRedisRepository instance
"
Class {
	#name : #MaplessRedisHelper,
	#superclass : #Object,
	#classInstVars : [
		'repository'
	],
	#category : #'Mapless-Redis-Observer'
}

{ #category : #initialization }
MaplessRedisHelper class >> initializeRepository [

	^ repository := MaplessRedisRepository
		                for: 5
		                with: MaplessRedisPool local
]

{ #category : #accessing }
MaplessRedisHelper class >> repository [

	^ repository ifNil: [ self initializeRepository ]
]

{ #category : #accessing }
MaplessRedisHelper class >> repository: aRepository [

	repository := aRepository
]

{ #category : #actions }
MaplessRedisHelper class >> reset [

	repository ifNotNil: [ repository shutDown ].
	repository := nil
]
