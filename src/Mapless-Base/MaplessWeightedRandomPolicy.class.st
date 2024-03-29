"
I help to randomly allocate resources with a custom weight that influences their likelyhood to be choosen.
"
Class {
	#name : #MaplessWeightedRandomPolicy,
	#superclass : #MaplessResourcePolicy,
	#instVars : [
		'nodes',
		'random',
		'totalWeight'
	],
	#category : #'Mapless-Base-Resources'
}

{ #category : #'instance creation' }
MaplessWeightedRandomPolicy class >> fromDictionary: weights seed: aRandomSeedValue [
	| newOne |
	newOne := self seed: aRandomSeedValue.
	weights
		keysAndValuesDo:
			[ :key :value | newOne addNode: (MaplessWeightedNode weight: value value: key) ].
	^ newOne
]

{ #category : #'instance creation' }
MaplessWeightedRandomPolicy class >> new [
	^ self seed: DateAndTime now asUnixTime
]

{ #category : #'instance creation' }
MaplessWeightedRandomPolicy class >> seed: anInteger [

	^ super new initializeOn: anInteger 
]

{ #category : #actions }
MaplessWeightedRandomPolicy >> addNode: aNode [
	self nodes add: aNode.
	self recalculateWeight.
	^ aNode
]

{ #category : #actions }
MaplessWeightedRandomPolicy >> getNext: aRandomValue [
	^ self nodes
		detect: [ :node | node matches: aRandomValue ]
		ifNone: [ self error: 'Improper weighted resource configuration' ]
]

{ #category : #initialization }
MaplessWeightedRandomPolicy >> initializeNodes [
	^ nodes := OrderedCollection new
]

{ #category : #initialization }
MaplessWeightedRandomPolicy >> initializeOn: anInteger [
	random := Random seed: anInteger.
	self recalculateWeight 
]

{ #category : #actions }
MaplessWeightedRandomPolicy >> next [
	"Returns the next resource node with a randomn probability that will follow the node's weight"

	^ self getNext: totalWeight * random next
]

{ #category : #actions }
MaplessWeightedRandomPolicy >> nextAmong: values [
	| nextOne |
	nextOne := self next.
	[ (values
		anySatisfy:
			[ :url | url port = nextOne value port and: [ url host = nextOne value host ] ])
		not ] whileTrue: [ nextOne := self next ].
	^ nextOne value
]

{ #category : #accessing }
MaplessWeightedRandomPolicy >> nodes [
	^ nodes ifNil: [ self initializeNodes ]
]

{ #category : #accessing }
MaplessWeightedRandomPolicy >> nodes: anObject [
	nodes := anObject
]

{ #category : #accessing }
MaplessWeightedRandomPolicy >> random [
	^ random
]

{ #category : #actions }
MaplessWeightedRandomPolicy >> recalculateWeight [
	totalWeight := self nodes
		inject: 0
		into: [ :sum :node | sum + node weight ].
	self nodes ifEmpty: [ ^ self ].
	self nodes first recalculateHeightOnTopOf: nil.
	self nodes reduceLeft: [ :a :b | b recalculateHeightOnTopOf: a ]
]

{ #category : #actions }
MaplessWeightedRandomPolicy >> removeNode: aNode [
	| target |
	target := self nodes remove: aNode ifAbsent: [ nil ].
	self recalculateWeight.
	^ target
]

{ #category : #accessing }
MaplessWeightedRandomPolicy >> totalWeight [
	^ totalWeight
]
