"
I'm a specialized API to help Mapless use MongoTalk
"
Class {
	#name : #MongoAPI,
	#superclass : #Mongo,
	#instVars : [
		'isPrimary',
		'mongoUrl'
	],
	#category : #'Mapless-Mongo-Connections'
}

{ #category : #'as yet unclassified' }
MongoAPI class >> mongoUrl: aString [
	| url |
	url := aString asMongoUrl.
	^ self host: url host port: url port
]

{ #category : #accessing }
MongoAPI >> asMongoUrl [
	^ (host , ':' , port asString) asMongoUrl
]

{ #category : #actions }
MongoAPI >> close [
	self triggerEvent: #closingConnection: with: self.
	super close
]

{ #category : #accessing }
MongoAPI >> getIsPrimary [
	^ self admin isMaster isPrimary
]

{ #category : #initializing }
MongoAPI >> initializeIsPrimary [
	^ isPrimary := self getIsPrimary
]

{ #category : #initializing }
MongoAPI >> initializeMongoUrl [
	^ mongoUrl := (host , ':' , port asString) asMongoUrl
]

{ #category : #testing }
MongoAPI >> isAt: aMongoUrlOrNil [
	"Answers true if this client is connected to the address represented in aMongoUrl."

	^ aMongoUrlOrNil notNil
		and: [ self host = aMongoUrlOrNil host
				and: [ self port = aMongoUrlOrNil port ] ]
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
MongoAPI >> isSecondary [
	^ self isPrimary not
]

{ #category : #testing }
MongoAPI >> isType: aSymbol [
	"Answers true if this MongoDB client is of type aSymbol.
	Supported types are #readOnly and #readWrite."

	^ self perform: ('is' , aSymbol capitalized) asSymbol
]

{ #category : #testing }
MongoAPI >> isValid [
	^ self isOpen
]

{ #category : #accessing }
MongoAPI >> mongoUrl [
	^ mongoUrl ifNil: [ self initializeMongoUrl ]
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
