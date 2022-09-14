"
I help to randomly allocate resources with a custom weight that influences their likelyhood to be choosen.
"
Class {
	#name : #MaplessWeightedNode,
	#superclass : #Object,
	#instVars : [
		'weight',
		'value',
		'top',
		'bottom'
	],
	#category : #'Mapless-Base-Core-Resources'
}

{ #category : #accessing }
MaplessWeightedNode >> bottom [
	^ bottom
]

{ #category : #accessing }
MaplessWeightedNode >> bottom: anObject [
	bottom := anObject
]

{ #category : #initialization }
MaplessWeightedNode >> initializeWeight [
	^ weight := 1
]

{ #category : #testing }
MaplessWeightedNode >> matches: aRandomValue [
	^ aRandomValue > bottom and: [ aRandomValue < top ]
]

{ #category : #printing }
MaplessWeightedNode >> printOn: aStream [
	super printOn: aStream.
	aStream << ('({1})' format: {value asString})
]

{ #category : #actions }
MaplessWeightedNode >> recalculateHeightOnTopOf: aWeightedNodeOrNil [
	aWeightedNodeOrNil
		ifNil: [ bottom := 0.
			top := weight ]
		ifNotNil: [ bottom := aWeightedNodeOrNil top.
			top := bottom + weight ]
]

{ #category : #accessing }
MaplessWeightedNode >> top [
	^ top
]

{ #category : #accessing }
MaplessWeightedNode >> top: anObject [
	top := anObject
]

{ #category : #accessing }
MaplessWeightedNode >> value [
	^ value
]

{ #category : #accessing }
MaplessWeightedNode >> value: anObject [
	value := anObject
]

{ #category : #accessing }
MaplessWeightedNode >> weight [
	^ weight ifNil: [ self initializeWeight ]
]

{ #category : #accessing }
MaplessWeightedNode >> weight: anObject [
	weight := anObject
]
