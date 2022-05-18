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

{ #category : #actions }
MaplessUnQLiteCursor >> close [
	cursor close
]

{ #category : #testing }
MaplessUnQLiteCursor >> currentIsValid [
	^ cursor currentIsValid
]

{ #category : #accessing }
MaplessUnQLiteCursor >> currentKey [
	^ cursor currentKey asString
]

{ #category : #accessing }
MaplessUnQLiteCursor >> currentValue [
	^ repository deserialize: cursor currentValue
]

{ #category : #accessing }
MaplessUnQLiteCursor >> cursor [
	^ cursor
]

{ #category : #actions }
MaplessUnQLiteCursor >> deleteCurrent [
	cursor deleteCurrent
]

{ #category : #enumeration }
MaplessUnQLiteCursor >> do: aBlock [
	"Evaluates aBlock using this cursor after moving it to the next key.
	Careful, its usage is limited as it starts in the first key 
	and finishes in the last one of the database."
	cursor do: [ :cur | aBlock value: self ]
]

{ #category : #enumeration }
MaplessUnQLiteCursor >> doEach: aBlock [
	"Evaluates aBlock with each Mapless retreived by this cursor.
	Careful, its usage is limited as it starts in the first key 
	and finishes in the last one of the database."

	cursor do: [ :cur | aBlock value: self currentValue ]
]

{ #category : #positioning }
MaplessUnQLiteCursor >> first [
	cursor first
]

{ #category : #enumeration }
MaplessUnQLiteCursor >> fromCurrentDoEach: aBlock [
	"Evaluates aBlock with each Mapless retreived by this cursor.
	Careful, its usage is limited as it starts in the first key 
	and finishes in the last one of the database."

	| currentKey lastKey |
	currentKey := cursor currentKey.
	cursor last.
	lastKey := cursor currentKey.
	cursor seek: currentKey.
	cursor
		fromCurrentDo: [ :cur | 
			aBlock value: self currentValue.
			cursor currentKey = lastKey
				ifTrue: [ ^ self ] ]
]

{ #category : #enumeration }
MaplessUnQLiteCursor >> fromCurrentReverseDoEach: aBlock [
	"Evaluates aBlock with each Mapless retreived by this cursor.
	Careful, its usage is limited as it starts in the last key 
	and finishes in the first one of the database."

	| currentKey firstKey |
	currentKey := cursor currentKey.
	cursor first.
	firstKey := cursor currentKey.
	cursor seek: currentKey.
	cursor
		fromCurrentReverseDo: [ :cur | 
			aBlock value: self currentValue.
			cursor currentKey = firstKey
				ifTrue: [ ^ self ] ]
]

{ #category : #initialization }
MaplessUnQLiteCursor >> initializeOn: aPqCursor in: aMaplessRepository [
	cursor := aPqCursor.
	repository := aMaplessRepository
]

{ #category : #testing }
MaplessUnQLiteCursor >> isOpen [
	^ cursor isOpen
]

{ #category : #positioning }
MaplessUnQLiteCursor >> last [
	cursor last
]

{ #category : #positioning }
MaplessUnQLiteCursor >> next [
	cursor next
]

{ #category : #positioning }
MaplessUnQLiteCursor >> previous [
	cursor previous
]

{ #category : #positioning }
MaplessUnQLiteCursor >> reset [
	cursor reset
]

{ #category : #enumeration }
MaplessUnQLiteCursor >> reverseDo: aBlock [
	"Evaluates aBlock using this cursor after moving it to the previous key.
	Careful, its usage is limited as it starts in the last key 
	and finishes in the first one of the database."

	cursor reverseDo: [ :cur | aBlock value: self ]
]

{ #category : #positioning }
MaplessUnQLiteCursor >> seekGreaterThan: key [
	cursor seekGreaterThan: key asByteArray
]

{ #category : #positioning }
MaplessUnQLiteCursor >> seekLessThan: key [
	cursor seekLessThan: key asByteArray
]
