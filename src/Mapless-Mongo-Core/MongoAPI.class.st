Class {
	#name : #MongoAPI,
	#superclass : #Mongo,
	#instVars : [
		'isPrimary'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #'as yet unclassified' }
MongoAPI class >> mongoUrl: aString [
	| url |
	url := aString asMongoUrl.
	^ self host: url host port: url port
]

{ #category : #initializing }
MongoAPI >> initializeIsPrimary [
	^ isPrimary := self admin isMaster isPrimary
]

{ #category : #testing }
MongoAPI >> isPrimary [
	^ isPrimary ifNil: [ self initializeIsPrimary ]
]

{ #category : #testing }
MongoAPI >> isReadOnly [
	^ self isPrimary not
]

{ #category : #testing }
MongoAPI >> isReadWrite [
	^ self isPrimary
]

{ #category : #testing }
MongoAPI >> isType: aSymbol [
	"Answers true if this MongoDB client is of type aSymbol.
	Supported types are #readOnly and #readWrite."

	^ self perform: ('is' , aSymbol capitalized) asSymbol
]

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

{ #category : #actions }
MongoAPI >> resetIsPrimary [
	isPrimary := nil
]
