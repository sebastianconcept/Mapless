Class {
	#name : #MaplessUnQLiteCursor,
	#superclass : #Object,
	#instVars : [
		'cursor',
		'repository'
	],
	#category : #'Mapless-UnQLite-Core-Connections'
}

{ #category : #'instance creation' }
MaplessUnQLiteCursor class >> on: aPqCursor in: aMaplessRepository [
	^ self new
		initializeOn: aPqCursor in: aMaplessRepository;
		yourself
]

{ #category : #accessing }
MaplessUnQLiteCursor >> currentKey [
	^ cursor currentKey asString
]

{ #category : #actions }
MaplessUnQLiteCursor >> currentValue [
	^ repository deserialize: cursor currentValue
]

{ #category : #actions }
MaplessUnQLiteCursor >> do: aBlock [
	"Evaluates aBlock using this cursor after moving it to the next key.
	Its usage is limited as it starts in the first key 
	and finishes in the last one of the database."
	cursor do: [ :cur | aBlock value: self ]
]

{ #category : #actions }
MaplessUnQLiteCursor >> doEach: aBlock [
	"Evaluates aBlock using with each Mapless retreived by this cursor.
	Careful, its usage is limited as it starts in the first key 
	and finishes in the last one of the database."

	cursor do: [ :cur | aBlock value: self currentValue ]
]

{ #category : #initialization }
MaplessUnQLiteCursor >> initializeOn: aPqCursor in: aMaplessRepository [
	cursor := aPqCursor.
	repository := aMaplessRepository
]
