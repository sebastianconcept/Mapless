Class {
	#name : #MaplessUnQLiteRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-UnQLite-Core-Core'
}

{ #category : #actions }
MaplessUnQLiteRepository class >> getNewId [
	^ UUID new
]

{ #category : #accessing }
MaplessUnQLiteRepository class >> idPropertyName [
	"Answers 'id' and we're using it as Postgres 
	primary key for the Mapless table of any given Mapless class."

	^ 'id'
]

{ #category : #accessing }
MaplessUnQLiteRepository class >> maplessDataPropertyName [
	"Answers'maplessData' as the column name 
	where we're going to use the Postgres JSON blob."

	^ 'maplessData'
]

{ #category : #actions }
MaplessUnQLiteRepository >> basicInsert: aBSONFriendlyObject as: aMaplessClass [
	self
		withClientDo:
			[ :client | client insert: aBSONFriendlyObject as: aMaplessClass in: self ]
]

{ #category : #actions }
MaplessUnQLiteRepository >> basicUpdate: aBSONFriendlyObject as: aMaplessClass [
	self
		withClientDo:
			[ :client | client update: aBSONFriendlyObject as: aMaplessClass in: self ]
]

{ #category : #querying }
MaplessUnQLiteRepository >> count: aMaplessClass [
	^ self count: aMaplessClass where: nil
]

{ #category : #querying }
MaplessUnQLiteRepository >> count: aMaplessClass where: conditions [
	^ self
		withClientDo: [ :client | client count: aMaplessClass where: conditions in: self ]
]

{ #category : #actions }
MaplessUnQLiteRepository >> createDatabase [
	self
		withClientDo: [ :client | client createDatabaseNamed: databaseName ]
]

{ #category : #actions }
MaplessUnQLiteRepository >> delete: aMapless [
	self onBeforeDelete: aMapless.
	aMapless deletedOn: DateAndTime now.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
	self onAfterDelete: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"

	self onBeforeDestroy: aMapless.
	self
		destroyAll: aMapless class
		where:
			('{1} = ''{2}'''
				format:
					{self idPropertyName.
					aMapless id}).
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> destroyAll: aMaplessClass [
	self withClientDo: [ :client | client truncate: aMaplessClass ]
]

{ #category : #actions }
MaplessUnQLiteRepository >> destroyAll: aMaplessClass where: condition [
	self
		withClientDo: [ :client | client destroyAll: aMaplessClass where: condition ]
]

{ #category : #actions }
MaplessUnQLiteRepository >> dropDatabase [
	self
		withClientDo: [ :client | client dropDatabaseNamed: databaseName ]
]

{ #category : #actions }
MaplessUnQLiteRepository >> ensureCollection [
	self shouldBeImplemented
]

{ #category : #actions }
MaplessUnQLiteRepository >> ensureDatabase [
	(MaplessPostgresRepository
		for: 'postgres'
		with: MaplessStandalonePostgresPool local)
		withClientDo: [ :client | 
			(client hasDatabaseNamed: databaseName)
				ifFalse: [ client createDatabaseNamed: databaseName ] ]
]

{ #category : #actions }
MaplessUnQLiteRepository >> ensureTableFor: aMaplessClass [
	self
		withClientDo: [ :client |
			(client hasTableFor: aMaplessClass)
				ifFalse: [ client createTableFor: aMaplessClass ] ]
]

{ #category : #testing }
MaplessUnQLiteRepository >> existsId: anId of: aMaplessClass [
	^ (self
		count: aMaplessClass
		where:
			('{1} = ''{2}'''
				format:
					{self idPropertyName.
					anId})) > 0
]

{ #category : #querying }
MaplessUnQLiteRepository >> findAll: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: nil
		offset: nil
]

{ #category : #querying }
MaplessUnQLiteRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: nil
]

{ #category : #querying }
MaplessUnQLiteRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: nil
]

{ #category : #querying }
MaplessUnQLiteRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [
	^ self
		withClientDo: [ :client | 
			client
				findAll: aMaplessClass
				where: someConditionsOrNil
				limit: aLimitOrNil
				offset: anOffsetOrNil
				sort: sortConditionsOrNil
				in: self ]
]

{ #category : #querying }
MaplessUnQLiteRepository >> findOne: aMapless atId: anId [
	^ self
		findOne: aMapless
		where:
			('{1} = ''{2}'''
				format:
					{self idPropertyName.
					anId})
]

{ #category : #querying }
MaplessUnQLiteRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |
	result := self findAll: aMaplessClass where: someConditions limit: 1.
	^ result isEmpty
		ifTrue: [ nil ]
		ifFalse: [ result first ]
]

{ #category : #testing }
MaplessUnQLiteRepository >> hasDatabase [
	"Answers true if the database was already created."

	^ self
		withClientDo: [ :client | client hasDatabaseNamed: databaseName ]
]

{ #category : #testing }
MaplessUnQLiteRepository >> hasTableFor: aMaplessClass [
	^ self withClientDo: [ :client | client hasTableFor: aMaplessClass ]
]

{ #category : #accessing }
MaplessUnQLiteRepository >> idPropertyName [
	^ self class idPropertyName
]

{ #category : #initialization }
MaplessUnQLiteRepository >> initializeOn: aDatabaseName with: aDatabaseAccessor using: aMaplessResolver [
	super
		initializeOn: aDatabaseName
		with: aDatabaseAccessor
		using: aMaplessResolver.
	aDatabaseAccessor databaseName: aDatabaseName
]

{ #category : #actions }
MaplessUnQLiteRepository >> insert: aMapless [
	| maplessData storable |
	self onBeforeInsert: aMapless.
	maplessData := resolver storableFor: aMapless in: self.
	storable := Dictionary new.
	maplessData
		at: self idPropertyName
		ifAbsent: [ storable
				at: self idPropertyName
				put: self class getNewId ].
	maplessData
		removeKey: self idPropertyName
		ifAbsent: [  ].
	storable
		at: self maplessDataPropertyName
		put: maplessData.
	self basicInsert: storable as: aMapless class.
	self ensureId: (storable at: self idPropertyName) for: aMapless.
	self onAfterInsert: aMapless
]

{ #category : #accessing }
MaplessUnQLiteRepository >> maplessDataPropertyName [
	^ self class maplessDataPropertyName
]

{ #category : #actions }
MaplessUnQLiteRepository >> normalizeIdOfOn: aJsonObject [
self halt.
	"aJsonObject at: 'id' put: (aJsonObject at: self idPropertyName).
	aJsonObject removeKey: self idPropertyName ifAbsent: [ nil ].
	^ aJsonObject"
]

{ #category : #reactions }
MaplessUnQLiteRepository >> onBeforeInsert: aMapless [
	self flag: #review. "not supported at the moment"
	aMapless ensurePrivateId.
	super onBeforeInsert: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> save: aMapless [
	"Storage this instance into the persistent collection.
	It will insert or update accordingly."

	self onBeforeSave: aMapless.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
	self onAfterSave: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> update: aMapless [
	| maplessData storable |
	self onBeforeUpdate: aMapless.
	maplessData := resolver storableFor: aMapless in: self.
	storable := Dictionary new.
	storable at: self idPropertyName put: aMapless id.
	maplessData removeKey: self idPropertyName ifAbsent: [  ].
	storable at: self maplessDataPropertyName put: maplessData.
	self basicUpdate: storable as: aMapless class.
	self onAfterUpdate: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> withClientDo: aBlock [
	"Performs aBlock and providing access to the postgres client as aBlock argument."

	^ accessor withClientDo: aBlock
]

{ #category : #actions }
MaplessUnQLiteRepository >> withNormalizedId: aValue [
	^ UUID newFrom: aValue 
]
