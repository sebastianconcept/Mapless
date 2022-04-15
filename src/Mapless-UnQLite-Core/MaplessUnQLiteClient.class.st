"
I'm the facade of the concrete library that will give us access to UnQLite
"
Class {
	#name : #MaplessUnQLiteClient,
	#superclass : #Object,
	#instVars : [
		'unqliteClient'
	],
	#category : #'Mapless-UnQLite-Core-Connections'
}

{ #category : #actions }
MaplessUnQLiteClient class >> inMemory [
	^ self on: ':mem:'
]

{ #category : #accessing }
MaplessUnQLiteClient class >> on: aDatabaseFileName [
	^ self new
		initializeOn: aDatabaseFileName;
		yourself
]

{ #category : #actions }
MaplessUnQLiteClient >> at: key [
	^ unqliteClient at: key
]

{ #category : #actions }
MaplessUnQLiteClient >> at: key ifAbsent: aBlock [
	^ unqliteClient at: key ifAbsent: aBlock
]

{ #category : #actions }
MaplessUnQLiteClient >> at: key ifAbsentPut: aBlock [
	^ unqliteClient at: key ifAbsentPut: aBlock
]

{ #category : #actions }
MaplessUnQLiteClient >> at: key ifPresent: aBlock [
	^ unqliteClient at: key ifPresent: aBlock
]

{ #category : #actions }
MaplessUnQLiteClient >> at: key put: value [
	^ unqliteClient at: key put: value
]

{ #category : #actions }
MaplessUnQLiteClient >> close [
	unqliteClient ifNotNil: [ unqliteClient close ]
]

{ #category : #actions }
MaplessUnQLiteClient >> disconnect [
	self close
]

{ #category : #testing }
MaplessUnQLiteClient >> hasDatabaseNamed: aDatabaseFileName [
	^ aDatabaseFileName asFileReference exists
]

{ #category : #testing }
MaplessUnQLiteClient >> includesKey: key [
	^ unqliteClient includesKey: key
]

{ #category : #initialization }
MaplessUnQLiteClient >> initializeOn: aDatabaseFileName [
	unqliteClient := aDatabaseFileName = ':mem:'
		ifTrue: [ PqDatabase openOnMemory ]
		ifFalse: [ PqDatabase open: aDatabaseFileName ]
]

{ #category : #testing }
MaplessUnQLiteClient >> isValid [
	^ unqliteClient isOpen
]

{ #category : #accessing }
MaplessUnQLiteClient >> keys [
	^ unqliteClient keys
]

{ #category : #actions }
MaplessUnQLiteClient >> maplessFromResult: aDictionarish in: aMaplessRepository [
	^ Mapless
		fromJSONObject: (JsonObject fromAssociations: aDictionarish associations)
		in: aMaplessRepository
]

{ #category : #actions }
MaplessUnQLiteClient >> newCursor [
	^ unqliteClient newCursor
]

{ #category : #actions }
MaplessUnQLiteClient >> removeKey: key [
	^ unqliteClient removeKey: key
]

{ #category : #actions }
MaplessUnQLiteClient >> removeKey: key ifAbsent: aBlock [
	^ unqliteClient removeKey: key ifAbsent: aBlock
]

{ #category : #actions }
MaplessUnQLiteClient >> reset [
	unqliteClient close
]

{ #category : #accessing }
MaplessUnQLiteClient >> size [
	^ unqliteClient size
]

{ #category : #accessing }
MaplessUnQLiteClient >> unqliteClient [
	^ unqliteClient
]

{ #category : #actions }
MaplessUnQLiteClient >> values [
	unqliteClient values
]
