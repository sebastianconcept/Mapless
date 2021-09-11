"
A MaplessRepository is an abstraction for the repositories supported by Mapless. Subclasses are concrete strategies for having Mapless supported by each technology.

Instance Variables
	databaseName:	holds the name of the database this repository will be working with. 
	accessor: holds what's needed to get an available client to the database service.
	
Look for the subclasses for concrete implementation details.


"
Class {
	#name : #MaplessRepository,
	#superclass : #Object,
	#instVars : [
		'databaseName',
		'accessor'
	],
	#category : #'Mapless-Base-Core-Repositories'
}

{ #category : #actions }
MaplessRepository class >> for: aDatabaseName with: aDatabaseAccessor [
	^ self new initializeOn: aDatabaseName with: aDatabaseAccessor
]

{ #category : #accessing }
MaplessRepository >> accessor [
	^ accessor
]

{ #category : #accessing }
MaplessRepository >> accessor: anObject [
	accessor := anObject
]

{ #category : #actions }
MaplessRepository >> addCollection: aCollectionName [
	^ self database addCollection: aCollectionName
]

{ #category : #actions }
MaplessRepository >> asStorable: anObject [
	^ anObject isCollection
		ifTrue: [ anObject class = OrderedJsonObject
				ifTrue: [ (JsonObject fromAssociations: anObject associations)
						collect: [ :e | self asStorable: e ] ]
				ifFalse: [ anObject collect: [ :e | self asStorable: e ] ] ]
		ifFalse: [ anObject class = MaplessReference
				ifFalse: [ (anObject isKindOf: Mapless)
						ifTrue: [ anObject asMaplessReference asJsonObject ]
						ifFalse: [ anObject ] ]
				ifTrue: [ (anObject hasModel not or: [ anObject isUnsaved not ])
						ifTrue: [ anObject asJsonObject ]
						ifFalse: [ MaplessUnsavedSubmodel
								signal:
									'This sub model is unsaved. You need to save all sub models before saving a composed model' ] ] ]
]

{ #category : #accessing }
MaplessRepository >> databaseCollectionNamed: aCollectionName [
	"Answers the collection for this kind of models hold by the current database"

	"self ensureCollectionNamed: aCollectionName."

	^ self database collectionAt: aCollectionName
]

{ #category : #accessing }
MaplessRepository >> databaseName [
	^ databaseName
]

{ #category : #actions }
MaplessRepository >> delete: aMapless [
	"Saves this instance as deleted in the persistent collection"

	self onBeforeDelete: aMapless.
	aMapless beDeleted.
	self save: aMapless.
	self onAfterDelete: aMapless
]

{ #category : #actions }
MaplessRepository >> denormalizeIdOf: aMapless [
	"Normalizes aMapless id for the concrete backend (instead of the Mapless API).
	'id' -> idAttritbute
	Makes sure that aMapless has the id attribute 
	under the right name for this concrete repository.
	Removes it from 'id' in case is present (not failing if absent)."

	"It's either already having the right one or it needs translation..."

	(aMapless maplessData includesKey: 'id')
		ifTrue: [ aMapless basicMaplessData at: self idPropertyName put: aMapless id ].

	"clean it.
	Note: if a concrete repo one day needs to use 'id' as id, then it needs to override this to not remove here."
	aMapless basicMaplessData removeKey: 'id' ifAbsent: [ nil ].
	^ aMapless
]

{ #category : #actions }
MaplessRepository >> do: aBlock [
	"Performs aBlock and provides access to the database to 
	anyone calling CurrentMongoDatabase value."

	MaplessCurrentRepository value: self during: [ ^ aBlock value ]
]

{ #category : #actions }
MaplessRepository >> ensureCollectionNamed: aCollectionName [
	"Makes sure there is a collection for this kind of models."

	(self hasCollectionNamed: aCollectionName)
		ifFalse: [ self addCollection: aCollectionName ]
]

{ #category : #accessing }
MaplessRepository >> find: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self subclassResponsibility
]

{ #category : #accessing }
MaplessRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	^ self subclassResponsibility
]

{ #category : #testing }
MaplessRepository >> hasCollectionNamed: aCollectionName [
	^ self database hasCollectionNamed: aCollectionName
]

{ #category : #initialization }
MaplessRepository >> initializeOn: aDatabaseName with: aDatabaseAccessor [
	databaseName := aDatabaseName.
	accessor := aDatabaseAccessor
]

{ #category : #testing }
MaplessRepository >> isUnsaved: aMapless [
	"Answer true if this instance was not saved yet.
	Note: we assume that if aMapless does not have an id 
	then is because the application never used the backend to saved it."

	^ aMapless basicMaplessId isNil and: [ aMapless id isNil ]
]

{ #category : #actions }
MaplessRepository >> normalizeIdOf: aMapless [
	"Normalizes aMapless id for the API.
	idAttritbute -> 'id'
	Makes sure that aMapless has the id attribute 
	under the name 'id' taking the information from this concrete repository.
	Removes it from the concrete place in case is present (not failing if absent)."

	"It's either already having the right one or it needs translation..."

	(aMapless basicMaplessData includesKey: self idPropertyName)
		ifTrue: [ aMapless basicMaplessData at: 'id' put: aMapless maplessId ].

	"clean it.
	Note: if a concrete repo one day needs to use 'id' as id, then it needs to override this to not remove here."
	aMapless data removeKey: self idPropertyName ifAbsent: [ nil ].
	^ aMapless
]

{ #category : #reactions }
MaplessRepository >> onAboutToDelete: aMapless [
	#deprecated.
	Transcript
		cr;
		nextPutAll:
			self class name
				, '>>onAboutToDelete: aMapless   is deprecated, use onBeforeDelete:'.
	self onBeforeDelete: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAboutToDestroy: aMapless [
	#deprecated.
	Transcript
		cr;
		nextPutAll:
			self class name
				, '>>onAboutToDestroy: aMapless   is deprecated, use onBeforeDestroy:'.
	self onBeforeDestroy: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAboutToInsert: aMapless [
	#deprecated.
	Transcript
		cr;
		nextPutAll:
			self class name
				, '>>onAboutToInsert: aMapless   is deprecated, use onBeforeInsert:'.
	self onBeforeInsert: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAboutToSave: aMapless [
	#deprecated.
	Transcript
		cr;
		nextPutAll:
			self class name
				, '>>onAboutToSave: aMapless   is deprecated, use onBeforeSave:'.
	self onBeforeSave: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAboutToUpdate: aMapless [
	#deprecated.
	Transcript
		cr;
		nextPutAll:
			self class name
				, '>>onAboutToUpdate: aMapless   is deprecated, use onBeforeUpdate:'.
	self onBeforeUpdate: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAfterDelete: aMapless [
	aMapless onAfterDelete
]

{ #category : #reactions }
MaplessRepository >> onAfterDestroy: aMapless [
	aMapless onAfterDestroy.
	self normalizeIdOf: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAfterInsert: aMapless [
	aMapless onAfterInsert.
	self normalizeIdOf: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAfterRead: aMapless [
	aMapless onAfterRead.
	self normalizeIdOf: aMapless.
	^ aMapless
]

{ #category : #reactions }
MaplessRepository >> onAfterSave: aMapless [
	aMapless onAfterSave.
	self normalizeIdOf: aMapless
]

{ #category : #reactions }
MaplessRepository >> onAfterUpdate: aMapless [
	aMapless onAfterUpdate.
	self normalizeIdOf: aMapless
]

{ #category : #reactions }
MaplessRepository >> onBeforeDelete: aMapless [
	aMapless onBeforeDelete
]

{ #category : #reactions }
MaplessRepository >> onBeforeDestroy: aMapless [
	aMapless onBeforeDestroy.
	self denormalizeIdOf: aMapless
]

{ #category : #reactions }
MaplessRepository >> onBeforeInsert: aMapless [
	aMapless onBeforeInsert.
	self denormalizeIdOf: aMapless
]

{ #category : #reactions }
MaplessRepository >> onBeforeSave: aMapless [
	aMapless onBeforeSave.
	self denormalizeIdOf: aMapless
]

{ #category : #reactions }
MaplessRepository >> onBeforeUpdate: aMapless [
	aMapless onBeforeUpdate.
	self denormalizeIdOf: aMapless
]

{ #category : #actions }
MaplessRepository >> shutDown [
	accessor stop
]

{ #category : #actions }
MaplessRepository >> startUp: anInteger [
	accessor start: anInteger
]

{ #category : #actions }
MaplessRepository >> storableFor: aJsonObject [
	"Returns a new JsonObject that's the BSON friendly version of aJsonObject
	by visinting all the values. It will complain if sub models are not previously saved."

	| storableDocument storablePart |
	storableDocument := JsonObject new.
	aJsonObject
		keysAndValuesDo: [ :key :value | 
			storablePart := self asStorable: value.
			storableDocument at: key put: storablePart ].
	^ storableDocument
]
