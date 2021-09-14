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
MaplessMemoryRepository >> count: aMaplessClass [
	"Answer what's the number of instances of aMaplessClass in this repository."

	^ (self databaseCollectionNamed: aMaplessClass collectionName) size
]

{ #category : #accessing }
MaplessMemoryRepository >> count: aMaplessClass where: someConditions [
	"Answer what's the number of instances of aMaplessClass in this repository."

	^ (self databaseCollectionNamed: aMaplessClass collectionName)
		sizeForQuery: someConditions
]

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
	self shouldBeImplemented
]

{ #category : #testing }
MaplessMemoryRepository >> existsId: anId of: aMaplessClass [
	^ (self findOne: aMaplessClass atId: anId) notNil
]

{ #category : #accessing }
MaplessMemoryRepository >> find: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditions
		limit: nil
		offset: nil
]

{ #category : #accessing }
MaplessMemoryRepository >> find: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: nil
]

{ #category : #accessing }
MaplessMemoryRepository >> find: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: nil
]

{ #category : #accessing }
MaplessMemoryRepository >> find: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	| result databaseCollection |
	databaseCollection := self
		databaseCollectionNamed: aMaplessClass collectionName.
	result := databaseCollection values select: someConditions.
	anOffsetOrNil
		ifNotNil: [ result := result
				copyFrom: anOffsetOrNil
				to: (result size min: anOffsetOrNil + aLimitOrNil) ].
	sortConditionsOrNil
		ifNotNil: [ result := (SortedCollection sortBlock: sortConditionsOrNil)
				addAll: result;
				yourself ].
	^ result collect: [ :each | self onAfterRead: each ]
]

{ #category : #accessing }
MaplessMemoryRepository >> find: aMaplessClass where: someConditions limit: aLimitOrNil sort: sortConditionsOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: nil
		sort: sortConditionsOrNil
]

{ #category : #accessing }
MaplessMemoryRepository >> find: aMaplessClass where: someConditions sort: sortConditionsOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditions
		limit: nil
		offset: nil
		sort: sortConditionsOrNil
]

{ #category : #accessing }
MaplessMemoryRepository >> findAll: aMaplessClass [
	^ self find: aMaplessClass where: [ :each | true ]
]

{ #category : #accessing }
MaplessMemoryRepository >> findAll: aMaplessClass sort: sortConditions [
	^ self
		find: aMaplessClass
		where: [ :each | true ]
		sort: sortConditions
]

{ #category : #accessing }
MaplessMemoryRepository >> findOne: aMaplessClass atId: anId [
	^ (self databaseCollectionNamed: aMaplessClass collectionName)
		findId: anId
]

{ #category : #accessing }
MaplessMemoryRepository >> findOne: aMaplessClass where: someConditions [
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
MaplessMemoryRepository >> idPropertyName [
	"Answers '_id' because we're using MongoDB here 
	and that's what Mongo uses as id."

	^ '_id'
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
