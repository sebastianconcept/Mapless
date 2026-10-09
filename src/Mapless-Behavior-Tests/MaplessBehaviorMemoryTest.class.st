"
MaplessBehaviorMemoryTest checks trait users against the memory repository.
When a class overrides a MaplessBehavior hook, the memory repository still runs that hook, including upsert.
"
Class {
	#name : #MaplessBehaviorMemoryTest,
	#superclass : #MaplessTestCase,
	#instVars : [
		'repository'
	],
	#category : #'Mapless-Behavior-Tests'
}

{ #category : #'setUp-tearDown' }
MaplessBehaviorMemoryTest >> setUp [

	super setUp.
	repository := MaplessMemoryRepository
		              for: 'Mapless-Behavior-Test'
		              with: MaplessMemoryAccessor new
		              using: MaplessMemoryCollectionToClassNameResolver new
]

{ #category : #'setUp-tearDown' }
MaplessBehaviorMemoryTest >> tearDown [

	repository ifNotNil: [
		repository
			drop;
			shutDown ].
	super tearDown
]

{ #category : #tests }
MaplessBehaviorMemoryTest >> testOverriddenHooksKeepTraitBehavior [
	"Given an ExampleUser that overrides the update and upsert hooks
	When the user is saved through the memory repository
	Then those overrides run without a missing-hook error and the user is marked modified"

	| user |
	user := ExampleUser new
		        username: 'hook';
		        yourself.
	self shouldnt: [ repository save: user ] raise: MessageNotUnderstood.
	self assert: user beforeUpdate.
	self assert: user beforeUpsert.
	self assert: user modifiedOn notNil
]
