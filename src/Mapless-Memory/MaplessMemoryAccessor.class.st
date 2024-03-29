"
Mostly a compatibility facade to make a repo based on RAM
"
Class {
	#name : #MaplessMemoryAccessor,
	#superclass : #Object,
	#instVars : [
		'databases'
	],
	#category : #'Mapless-Memory'
}

{ #category : #operations }
MaplessMemoryAccessor >> databaseNamed: aString [
	^ databases
		at: aString
		ifAbsentPut: [ MaplessMemoryDatabase newNamed: aString ]
]

{ #category : #actions }
MaplessMemoryAccessor >> do: aBlock [
	^ aBlock value
]

{ #category : #testing }
MaplessMemoryAccessor >> hasHealthChecker [
	^ false
]

{ #category : #operations }
MaplessMemoryAccessor >> initialize [
	super initialize.
	databases := Dictionary new
]

{ #category : #actions }
MaplessMemoryAccessor >> start [
	"For compatibility"

	
]

{ #category : #actions }
MaplessMemoryAccessor >> start: anInteger [
	"For compatibility"

	
]

{ #category : #actions }
MaplessMemoryAccessor >> stop [
	"For compatibility"

	
]
