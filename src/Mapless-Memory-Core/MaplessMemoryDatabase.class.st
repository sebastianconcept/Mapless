"
A memory based database. It can store many database collections
"
Class {
	#name : #MaplessMemoryDatabase,
	#superclass : #Object,
	#instVars : [
		'databaseName',
		'collections'
	],
	#category : #'Mapless-Memory-Core'
}

{ #category : #'instance creation' }
MaplessMemoryDatabase class >> newNamed: aString [
	^ self new
		databaseName: aString;
		yourself
]

{ #category : #accessing }
MaplessMemoryDatabase >> collectionNamed: aString [
	^ collections
		at: aString
		ifAbsentPut: [ MaplessMemoryCollection newNamed: aString ]
]

{ #category : #accessing }
MaplessMemoryDatabase >> collections [
	^ collections
]

{ #category : #accessing }
MaplessMemoryDatabase >> databaseName [
	^ databaseName
]

{ #category : #accessing }
MaplessMemoryDatabase >> databaseName: anObject [
	databaseName := anObject
]

{ #category : #actions }
MaplessMemoryDatabase >> drop [
	self initializeCollections
]

{ #category : #accessing }
MaplessMemoryDatabase >> initialize [
	super initialize.
	self initializeCollections
]

{ #category : #accessing }
MaplessMemoryDatabase >> initializeCollections [
	collections := Dictionary new
]
