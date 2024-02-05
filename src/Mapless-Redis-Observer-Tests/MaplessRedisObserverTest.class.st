Class {
	#name : #MaplessRedisObserverTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Redis-Observer-Tests'
}

{ #category : #'as yet unclassified' }
MaplessRedisObserverTest class >> databaseIndex [
	"Out of the box, a Redis instance supports 16 logical databases. These databases are effectively siloed off from one another, and when you run a command in one database it doesn’t affect any of the data stored in other databases in your Redis instance.

Redis databases are numbered from 0 to 15 and, by default, you connect to database 0 when you connect to your Redis instance. However, you can change the database you’re using with the select command after you connect."

	^ 2
]

{ #category : #actions }
MaplessRedisObserverTest >> basicNewRepository [
	^ MaplessRedisRepository
		for: self class databaseIndex
		with: MaplessRedisPool local
		using: MaplessTrivialResolver new
]

{ #category : #actions }
MaplessRedisObserverTest >> newRepository [
	| accessor |
	accessor := MaplessRedisPool local.
	accessor start.
	^ MaplessRedisRepository
		for: self class databaseIndex
		with: accessor
		using: MaplessTrivialResolver new
]

{ #category : #initialization }
MaplessRedisObserverTest >> setUp [
	super setUp.


]

{ #category : #initialization }
MaplessRedisObserverTest >> tearDown [
	super tearDown.
	repository
		ifNotNil: [ repository drop.
			repository accessor stop ]
]

{ #category : #tests }
MaplessRedisObserverTest >> testCanSubscribeToSavedMapless [

	| task valued reaction |
	repository := self newRepository.
	task := SampleTask new.
	valued := false.
	reaction := [ valued := true ].
	repository save: task.
	self
		shouldnt: [ task publish: #something send: #value to: reaction ]
		raise: MaplessObserverOnUnsaved
]

{ #category : #tests }
MaplessRedisObserverTest >> testCannotSubscribeToUnsavedMapless [

	| task valued reaction |
	repository := self newRepository.
	task := SampleTask new.
	valued := false.
	reaction := [ valued := true ].
	self
		should: [ task publish: #something send: #value to: reaction ]
		raise: MaplessObserverOnUnsaved
]

{ #category : #tests }
MaplessRedisObserverTest >> testReactsToAnObservedInstanceAmongMany [

	| task1 task2 valued reaction task3 |
	MaplessRedisHelper repository: self newRepository.
	repository := MaplessRedisHelper repository.
	task1 := SampleTask new.
	task2 := SampleTask new.
	task3 := SampleTask new.
	valued := Dictionary new.
	reaction := [ :id | valued at: id ifAbsentPut: [ true ] ].
	{ 
		task1.
		task2.
		task3 } do: [ :task | repository save: task ].

	task1
		subscribe: #doTheThing
		send: #value:
		to: reaction
		with: task1 id.
	self deny: (valued includesKey: task1 id).
	task2 := repository findOne: SampleTask atId: task2 id.
	task2 publish: #doTheThing.
	self deny: (valued includesKey: task1 id).
	self deny: (valued includesKey: task2 id).
	self deny: (valued includesKey: task3 id).
	
	task3 := repository findOne: SampleTask atId: task3 id.
	task3 publish: #doTheThing.
	self deny: (valued includesKey: task1 id).
	self deny: (valued includesKey: task2 id).
	self deny: (valued includesKey: task3 id).

	task1 := repository findOne: SampleTask atId: task1 id.
	task1 publish: #doTheThing.

	5 milliSeconds asDelay wait.
	self assert: (valued includesKey: task1 id).
	self deny: (valued includesKey: task2 id).
	self deny: (valued includesKey: task3 id)
]

{ #category : #tests }
MaplessRedisObserverTest >> testReactsToObservedPubsubEventWithLocalArguments [

	| task1 task2 valued reaction receivedOne receivedTwo |
	MaplessRedisHelper repository: self newRepository.
	repository := MaplessRedisHelper repository.
	task1 := SampleTask new.
	valued := false.
	reaction := [ :first :second | 
	            valued := true.
	            receivedOne := first.
	            receivedTwo := second ].
	repository save: task1.
	self deny: valued.
	task1
		subscribe: #doTheThing
		send: #value:value:
		to: reaction
		withArguments: { $a. 42 }.
	self deny: valued.
	task2 := repository findOne: SampleTask atId: task1 id.

	task2 publish: #doTheThing.
	5 milliSeconds asDelay wait.
	self assert: valued.
	self assert: receivedOne equals: $a.
	self assert: receivedTwo equals: 42
]

{ #category : #tests }
MaplessRedisObserverTest >> testReactsToObservedPubsubEventWithOneLocalArgument [

	| task1 task2 valued reaction receivedArguments |
	MaplessRedisHelper repository: self newRepository.
	repository := MaplessRedisHelper repository.
	task1 := SampleTask new.
	valued := false.
	reaction := [ :args | 
	            valued := true.
	            receivedArguments := args ].
	repository save: task1.
	self deny: valued.
	task1
		subscribe: #doTheThing
		send: #value:
		to: reaction
		with: 42.
	self deny: valued.
	self assert: receivedArguments isNil.
	task2 := repository findOne: SampleTask atId: task1 id.
	task2 publish: #doTheThing.
	5 milliSeconds asDelay wait.
	self assert: valued.
	self assert: receivedArguments notNil.
	self assert: receivedArguments equals: 42
]

{ #category : #tests }
MaplessRedisObserverTest >> testReactsToObservedPubsubEventWithRemoteArgument [

	| task1 task2 valued reaction received |
	MaplessRedisHelper repository: self newRepository.
	repository := MaplessRedisHelper repository.
	task1 := SampleTask new.
	valued := false.
	reaction := [ :first | 
	            valued := true.
	            received := first ].
	repository save: task1.
	self deny: valued.
	task1
		subscribe: #doTheThing
		send: #value:
		to: reaction.
	self deny: valued.
	self deny: received equals: 42.
	task2 := repository findOne: SampleTask atId: task1 id.

	task2 publish: #doTheThing with: 42.
	5 milliSeconds asDelay wait.
	self assert: valued.
	self assert: received equals: 42
]

{ #category : #tests }
MaplessRedisObserverTest >> testReactsToObservedPubsubEventWithRemoteArguments [

	| task1 task2 valued reaction receivedOne receivedTwo |
	MaplessRedisHelper repository: self newRepository.
	repository := MaplessRedisHelper repository.
	task1 := SampleTask new.
	valued := false.
	reaction := [ :first :second | 
	            valued := true.
	            receivedOne := first.
	            receivedTwo := second ].
	repository save: task1.
	self deny: valued.
	task1
		subscribe: #doTheThing
		send: #value:value:
		to: reaction.
	self deny: valued.
	self deny: receivedOne equals: $a.
	self deny: receivedTwo equals: 42.
	task2 := repository findOne: SampleTask atId: task1 id.

	task2 publish: #doTheThing withArguments: { $a. 42 }.
	5 milliSeconds asDelay wait.
	self assert: valued.
	self assert: receivedOne equals: $a.
	self assert: receivedTwo equals: 42
]

{ #category : #tests }
MaplessRedisObserverTest >> testReactsToObservedPubsubEventWithoutArguments [

	| task1 task2 valued reaction |
	MaplessRedisHelper repository: self newRepository.
	repository := MaplessRedisHelper repository.
	task1 := SampleTask new.
	valued := false.
	reaction := [ valued := true ].
	repository save: task1.
	self deny: valued.
	task1 publish: #doTheThing send: #value to: reaction.
	self deny: valued.
	task2 := repository findOne: SampleTask atId: task1 id.

	task2 publish: #doTheThing.
	5 milliSeconds asDelay wait.
	self assert: valued
]

{ #category : #tests }
MaplessRedisObserverTest >> testThreeRemoteArguments [

	| task1 task2 valued reaction receivedOne receivedTwo receivedThree |
	MaplessRedisHelper repository: self newRepository.
	repository := MaplessRedisHelper repository.
	task1 := SampleTask new.
	valued := false.
	reaction := [ :first :second :third | 
	            valued := true.
	            receivedOne := first.
	            receivedTwo := second.
	            receivedThree := third ].
	repository save: task1.
	self deny: valued.
	task1
		subscribe: #doTheThing
		send: #value:value:value:
		to: reaction.
	self deny: valued.
	task2 := repository findOne: SampleTask atId: task1 id.

	task2
		publish: #doTheThing
		withArguments: { $a. 42. #answer }.
	5 milliSeconds asDelay wait.
	self assert: valued.
	self assert: receivedOne equals: $a.
	self assert: receivedTwo equals: 42.
	self assert: receivedThree equals: #answer
]
