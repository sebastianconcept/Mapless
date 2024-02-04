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
		shouldnt: [ task pubsubWhen: #something send: #value to: reaction ]
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
		should: [ task pubsubWhen: #something send: #value to: reaction ]
		raise: MaplessObserverOnUnsaved
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
		pubsubWhen: #doTheThing
		send: #value:value:
		to: reaction
		withArguments: { $a. 42 }.
	self deny: valued.
	task2 := repository findOne: SampleTask atId: task1 id.

	task2 pubsubTriggerEvent: #doTheThing.
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
		pubsubWhen: #doTheThing
		send: #value:
		to: reaction
		with: 42.
	self deny: valued.
	self assert: receivedArguments isNil.
	task2 := repository findOne: SampleTask atId: task1 id.
	Transcript crShow: valued.
	task2 pubsubTriggerEvent: #doTheThing.
	5 milliSeconds asDelay wait.
	self assert: valued.
	self assert: receivedArguments notNil.
	self assert: receivedArguments equals: 42
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
	task1 pubsubWhen: #doTheThing send: #value to: reaction.
	self deny: valued.
	task2 := repository findOne: SampleTask atId: task1 id.

	task2 pubsubTriggerEvent: #doTheThing.
	5 milliSeconds asDelay wait.
	self assert: valued
]
