"
This repo uses RAM to give you the same API as the other ones
"
Class {
	#name : #MaplessMemoryRepository,
	#superclass : #MaplessRepository,
	#instVars : [
		'client'
	],
	#category : #'Mapless-Memory-Core'
}

{ #category : #accessing }
MaplessMemoryRepository >> database [
	^ accessor databaseNamed: databaseName
]

{ #category : #accessing }
MaplessMemoryRepository >> databaseCollectionNamed: aCollectionName [
	"Answers the collection for this kind of models hold by the current database"

	^ self database collectionNamed: aCollectionName
]

{ #category : #actions }
MaplessMemoryRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"

	self onBeforeDestroy: aMapless.
	(self databaseCollectionNamed: aMapless class collectionName)
		remove: aMapless.
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessMemoryRepository >> do: aBlock [
	^ self do: aBlock with: accessor
]

{ #category : #actions }
MaplessMemoryRepository >> do: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client in use during this thread to 
	anyone calling MaplessCurrentRepository value."

	aDatabaseAccessor
		do: [ [ MaplessCurrentRepository value: self during: [ ^ aBlock value ] ]
				ensure: [  ] ]
]

{ #category : #accessing }
MaplessMemoryRepository >> drop [
	^ self do: [ self database drop ]
]

{ #category : #actions }
MaplessMemoryRepository >> ensureCollection [
	self shouldBeImplemented.
]

{ #category : #testing }
MaplessMemoryRepository >> existsId: anId of: aMaplessClass [

	^ ( self instanceOf: aMaplessClass  atId:  anId ) notNil
]

{ #category : #accessing }
MaplessMemoryRepository >> idAttribute [
	"Answers '_id' because we're using MongoDB here 
	and that's what Mongo uses as id."

	^ '_id'
]

{ #category : #accessing }
MaplessMemoryRepository >> instanceOf: aMaplessClass atId: anId [
	^ (self databaseCollectionNamed: aMaplessClass collectionName)
		findId: anId
]

{ #category : #accessing }
MaplessMemoryRepository >> instanceOf: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result databaseCollection |
	databaseCollection := self
		databaseCollectionNamed: aMaplessClass collectionName.
	result := databaseCollection values
		detect: someConditions
		ifNone: [ nil ].
	^ result isNil
		ifTrue: [ nil ]
		ifFalse: [ result ]
]

{ #category : #accessing }
MaplessMemoryRepository >> instancesOf: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^self instancesOf: aMaplessClass where: someConditions limit: nil offset: nil
]

{ #category : #accessing }
MaplessMemoryRepository >> instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^self instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: nil
]

{ #category : #accessing }
MaplessMemoryRepository >> instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	| result databaseCollection |
	databaseCollection := self
		databaseCollectionNamed: aMaplessClass collectionName.
	result := databaseCollection values select: someConditions.
	anOffsetOrNil notNil
		ifTrue: [ result := result
				copyFrom: anOffsetOrNil
				to: (result size min: anOffsetOrNil + aLimitOrNil) ].
	^ result collect: [ :each | self onAfterRead: each ]
]

{ #category : #actions }
MaplessMemoryRepository >> onBeforeSave: aMapless [

	aMapless ensureId.

	super onBeforeSave: aMapless
]

{ #category : #actions }
MaplessMemoryRepository >> save: aMapless [
	"Storage this instance into the persistent collection"

	self onBeforeSave: aMapless.
	(self databaseCollectionNamed: aMapless class collectionName)
		add: aMapless.
	self onAfterSave: aMapless.
	^ aMapless
]
