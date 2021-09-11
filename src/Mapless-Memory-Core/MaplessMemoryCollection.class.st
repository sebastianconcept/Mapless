"
A database collection supported by Dictionary in RAM
"
Class {
	#name : #MaplessMemoryCollection,
	#superclass : #Object,
	#instVars : [
		'name',
		'elements'
	],
	#category : #'Mapless-Memory-Core'
}

{ #category : #'instance creation' }
MaplessMemoryCollection class >> newNamed: aString [
	^ self new
		name: aString;
		yourself
]

{ #category : #accessing }
MaplessMemoryCollection >> add: anObject [
	^ elements
		at: (anObject data at: anObject class idAttribute)
		put: anObject
]

{ #category : #accessing }
MaplessMemoryCollection >> elements [
	^ elements
]

{ #category : #accessing }
MaplessMemoryCollection >> elements: anObject [
	elements := anObject
]

{ #category : #accessing }
MaplessMemoryCollection >> findId: anOID [
	^ elements at: anOID ifAbsent: [ nil ]
]

{ #category : #testing }
MaplessMemoryCollection >> includes: anObject [
	^ elements includesKey: anObject id
]

{ #category : #accessing }
MaplessMemoryCollection >> initialize [
	super initialize.
	elements := Dictionary new
]

{ #category : #testing }
MaplessMemoryCollection >> isEmpty [
	^ elements isEmpty
]

{ #category : #accessing }
MaplessMemoryCollection >> name [
	^ name
]

{ #category : #accessing }
MaplessMemoryCollection >> name: anObject [
	name := anObject
]

{ #category : #accessing }
MaplessMemoryCollection >> remove: anObject [
	^ elements
		removeKey: (anObject data at: anObject class idAttribute)
		ifAbsent: [ "ignore" ]
]

{ #category : #accessing }
MaplessMemoryCollection >> size [
	^ elements size
]

{ #category : #accessing }
MaplessMemoryCollection >> sizeForQuery: someConditions [
	someConditions isClosure
		ifFalse: [ self
				error:
					'This repository is based on a Dictionary, use a regular block for the conditions' ].
	^ (self elements select: someConditions) size
]

{ #category : #accessing }
MaplessMemoryCollection >> values [
	^ elements values
]
