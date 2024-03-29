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
		'accessor',
		'resolver'
	],
	#category : #'Mapless-Base-Repositories'
}

{ #category : #actions }
MaplessRepository class >> for: aDatabaseName with: aDatabaseAccessor [
	^ self
		for: aDatabaseName
		with: aDatabaseAccessor
		using: MaplessCollectionToClassNameResolver new
]

{ #category : #actions }
MaplessRepository class >> for: aDatabaseName with: aDatabaseAccessor using: aMaplessResolver [
	^ self new
		initializeOn: aDatabaseName
			with: aDatabaseAccessor
			using: aMaplessResolver;
		yourself
]

{ #category : #actions }
MaplessRepository class >> getNewId [
	^ self subclassResponsibility
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
MaplessRepository >> asStorable: anObject [
	^ anObject isCollection
		ifTrue: [ anObject class = OrderedJsonObject
				ifTrue: [ (JsonObject fromAssociations: anObject associations)
						collect: [ :e | resolver maplessAsStorable: e in: self ] ]
				ifFalse: [ anObject collect: [ :e | self asStorable: e ] ] ]
		ifFalse: [ anObject class = MaplessReference
				ifFalse: [ (anObject isKindOf: Mapless)
						ifTrue: [ (resolver asMaplessReferenceIn: anObject in: self)
								asJsonObjectIn: self ]
						ifFalse: [ anObject ] ]
				ifTrue: [ (anObject hasModel and: [ anObject data id isNil ])
						ifFalse: [ resolver maplessReferenceAsJsonObject: anObject in: self ]
						ifTrue: [ MaplessUnsavedSubmodel
								signal:
									'This sub model is unsaved. You need to save all sub models before saving a composed model' ] ] ]
]

{ #category : #testing }
MaplessRepository >> canBeMapless: anObject [
	"Answers true if anObject can be used to instantiate mapless."

	^ anObject isDictionary
		and: [ anObject size > 1 and: [ anObject includesKey: '_c' ] ]
]

{ #category : #testing }
MaplessRepository >> canRepresentArrayOfMaplessReferences: anObject [
	"Answers true if anObject can represent a collection of sub mapless references."

	^ resolver canRepresentArrayOfMaplessReferences: anObject in: self
]

{ #category : #testing }
MaplessRepository >> canRepresentSubMapless: anObject [
	^ resolver canRepresentSubMapless: anObject in: self
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
MaplessRepository >> do: aBlock [
	"Performs aBlock and provides access to the database to 
	anyone calling CurrentMongoDatabase value."

	MaplessCurrentRepository value: self during: [ ^ aBlock value ]
]

{ #category : #actions }
MaplessRepository >> ensureId: anId for: aMapless [
	aMapless maplessData
		at: self idPropertyName
		ifAbsent: [ aMapless maplessData
				at: 'id' put: anId;
				at: self idPropertyName put: anId ]
]

{ #category : #actions }
MaplessRepository >> ensureIdOf: aMapless [
	self ensureId: self class getNewId for: aMapless
]

{ #category : #accessing }
MaplessRepository >> findAll: aMaplessClass where: someConditions [
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

{ #category : #accessing }
MaplessRepository >> idOf: aMapless [
	^ aMapless maplessData at: self idPropertyName
]

{ #category : #initialization }
MaplessRepository >> initializeOn: aDatabaseName with: aDatabaseAccessor using: aMaplessResolver [
	databaseName := aDatabaseName.
	accessor := aDatabaseAccessor.
	resolver := aMaplessResolver
]

{ #category : #testing }
MaplessRepository >> isUnsaved: aMapless [
	"Answer true if this instance was not saved yet.
	Note: we assume that if aMapless does not have an id 
	then is because the application never used the backend to saved it."

	^ (aMapless maplessData includesKey: self idPropertyName) not
		and: [ (aMapless maplessData includesKey: 'id') not ]
]

{ #category : #accessing }
MaplessRepository >> maplessClassFor: aJsonObject [
	^ resolver maplessClassFor: aJsonObject in: self
]

{ #category : #accessing }
MaplessRepository >> maplessReferenceAsJsonObject: aMaplessReference [
	^ resolver maplessReferenceAsJsonObject: aMaplessReference in: self
]

{ #category : #actions }
MaplessRepository >> normalizeIdOfOn: aJsonObject [
	^ self subclassResponsibility
]

{ #category : #hooks }
MaplessRepository >> onAfterDelete: aMapless [
	aMapless onAfterDelete.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onAfterDestroy: aMapless [
	aMapless onAfterDestroy.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onAfterInsert: aMapless [
	aMapless onAfterInsert.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onAfterRead: aMapless [
	aMapless onAfterRead.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onAfterSave: aMapless [
	aMapless onAfterSave.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onAfterUpdate: aMapless [
	aMapless onAfterUpdate.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onAfterUpsert: aMapless [
	aMapless onAfterUpsert.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onBeforeDelete: aMapless [
	aMapless onBeforeDelete.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onBeforeDestroy: aMapless [
	aMapless onBeforeDestroy.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onBeforeInsert: aMapless [
	aMapless onBeforeInsert.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onBeforeSave: aMapless [
	aMapless onBeforeSave.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onBeforeUpdate: aMapless [
	aMapless onBeforeUpdate.
	^ aMapless
]

{ #category : #hooks }
MaplessRepository >> onBeforeUpsert: aMapless [
	aMapless onBeforeUpsert.
	^ aMapless
]

{ #category : #accessing }
MaplessRepository >> referenceDataFrom: aJsonObject [
	^ resolver referenceDataFrom: aJsonObject in: self
]

{ #category : #accessing }
MaplessRepository >> resolver [
	^ resolver
]

{ #category : #accessing }
MaplessRepository >> resolver: anObject [
	resolver := anObject
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
MaplessRepository >> withNormalizedId: aValue [
	^ aValue
]
