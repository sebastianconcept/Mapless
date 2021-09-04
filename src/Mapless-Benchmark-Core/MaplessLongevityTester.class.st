"
Helper class that can start/stop and spawn workers to do a long lasting test.

Usage to spawn 5 workers:
MaplessLongevityTester start: 5.

MaplessLongevityTester stop.

Clean up state from preivous run:
MaplessLongevityTester reset.

MaplessLongevityTester dropDatabase 
"
Class {
	#name : #MaplessLongevityTester,
	#superclass : #Object,
	#classInstVars : [
		'timer',
		'workers'
	],
	#category : #'Mapless-Benchmark-Core'
}

{ #category : #actions }
MaplessLongevityTester class >> addWorkerNamed: aString [
	| worker |
	worker := MaplessLongevityTest new
		name: aString;
		yourself.
	self workers add: worker.
	worker when: #reported send: #onReported: to: self.
	^ worker
]

{ #category : #actions }
MaplessLongevityTester class >> consistencyCheck [
	self workers do: [ :each | each startConsistencyCheck ]
]

{ #category : #accessing }
MaplessLongevityTester class >> consistencyCheckEvery [
	^ 5 seconds
]

{ #category : #actions }
MaplessLongevityTester class >> dropDatabase [
	MaplessMongoPool instance
		do: [ :client | (client databaseNamed: 'Mapless-Tests') drop ]
]

{ #category : #initialization }
MaplessLongevityTester class >> initializeTimer [
	^ timer := [ [ self consistencyCheckEvery wait.
	self consistencyCheck ] repeat ]
		forkNamed: 'MaplessLongevityTesterTimer'
]

{ #category : #initialization }
MaplessLongevityTester class >> initializeWorkers [
	^ workers := OrderedCollection new
]

{ #category : #actions }
MaplessLongevityTester class >> onReported: aWorker [
	
]

{ #category : #actions }
MaplessLongevityTester class >> reset [
	timer ifNotNil: [ timer terminate ].
	timer := nil.
	workers := nil
]

{ #category : #actions }
MaplessLongevityTester class >> setUp [
	
]

{ #category : #actions }
MaplessLongevityTester class >> start [
	self start: 1
]

{ #category : #actions }
MaplessLongevityTester class >> start: quantityOfWorkers [
	1 to: quantityOfWorkers do: [ :i | self addWorkerNamed: 'Worker ' , i asString ].
	self workers do: [ :e | e start ].
	self timer resume
]

{ #category : #actions }
MaplessLongevityTester class >> stop [
	self workers do: [ :e | e stop ].
	self timer terminate
]

{ #category : #accessing }
MaplessLongevityTester class >> timer [
	^ timer ifNil: [ self initializeTimer ]
]

{ #category : #accessing }
MaplessLongevityTester class >> workers [
	^ workers ifNil: [ self initializeWorkers ]
]
