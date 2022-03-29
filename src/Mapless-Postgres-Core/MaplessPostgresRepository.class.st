"
I prodvide mapless repository access using a PostgreSQL backend.
"
Class {
	#name : #MaplessPostgresRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-Postgres-Core-Connections'
}

{ #category : #actions }
MaplessPostgresRepository class >> getNewId [
	^ UUID new
]

{ #category : #accessing }
MaplessPostgresRepository class >> idPropertyName [
	"Answers 'id' and we're using it as Postgres 
	primary key for the Mapless table of any given Mapless class."

	^ 'id'
]

{ #category : #accessing }
MaplessPostgresRepository class >> maplessDataPropertyName [
	"Answers'maplessData' as the column name 
	where we're going to use the Postgres JSON blob."

	^ 'maplessData'
]

{ #category : #actions }
MaplessPostgresRepository >> basicInsert: aBSONFriendlyObject as: aMaplessClass [
	self
		withClientDo:
			[ :client | client insert: aBSONFriendlyObject as: aMaplessClass in: self ]
]

{ #category : #actions }
MaplessPostgresRepository >> basicUpdate: aBSONFriendlyObject as: aMaplessClass [
	self
		withClientDo:
			[ :client | client update: aBSONFriendlyObject as: aMaplessClass in: self ]
]

{ #category : #querying }
MaplessPostgresRepository >> count: aMaplessClass [
	^ self count: aMaplessClass where: nil
]

{ #category : #querying }
MaplessPostgresRepository >> count: aMaplessClass where: conditions [
	^ self
		withClientDo: [ :client | client count: aMaplessClass where: conditions in: self ]
]

{ #category : #actions }
MaplessPostgresRepository >> createDatabase [
	self
		withClientDo: [ :client | client createDatabaseNamed: databaseName ]
]

{ #category : #actions }
MaplessPostgresRepository >> delete: aMapless [
	self onBeforeDelete: aMapless.
	aMapless deletedOn: DateAndTime now.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
	self onAfterDelete: aMapless
]

{ #category : #actions }
MaplessPostgresRepository >> destroy: aMapless [
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
MaplessPostgresRepository >> destroyAll: aMaplessClass [
	self withClientDo: [ :client | client truncate: aMaplessClass ]
]

{ #category : #actions }
MaplessPostgresRepository >> destroyAll: aMaplessClass where: condition [
	self
		withClientDo: [ :client | client destroyAll: aMaplessClass where: condition ]
]

{ #category : #actions }
MaplessPostgresRepository >> dropDatabase [
	self
		withClientDo: [ :client | client dropDatabaseNamed: databaseName ]
]

{ #category : #actions }
MaplessPostgresRepository >> ensureCollection [
	self shouldBeImplemented
]

{ #category : #actions }
MaplessPostgresRepository >> ensureDatabase [
	(MaplessPostgresRepository
		for: 'postgres'
		with: MaplessStandalonePostgresPool local)
		withClientDo: [ :client | 
			(client hasDatabaseNamed: databaseName)
				ifFalse: [ client createDatabaseNamed: databaseName ] ]
]

{ #category : #actions }
MaplessPostgresRepository >> ensureTableFor: aMaplessClass [
	self
		withClientDo: [ :client |
			(client hasTableFor: aMaplessClass)
				ifFalse: [ client createTableFor: aMaplessClass ] ]
]

{ #category : #testing }
MaplessPostgresRepository >> existsId: anId of: aMaplessClass [
	^ (self
		count: aMaplessClass
		where:
			('{1} = ''{2}'''
				format:
					{self idPropertyName.
					anId})) > 0
]

{ #category : #querying }
MaplessPostgresRepository >> findAll: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: nil
		offset: nil
]

{ #category : #querying }
MaplessPostgresRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: nil
]

{ #category : #querying }
MaplessPostgresRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: nil
]

{ #category : #querying }
MaplessPostgresRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [
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
MaplessPostgresRepository >> findOne: aMapless atId: anId [
	^ self
		findOne: aMapless
		where:
			('{1} = ''{2}'''
				format:
					{self idPropertyName.
					anId})
]

{ #category : #querying }
MaplessPostgresRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |
	result := self findAll: aMaplessClass where: someConditions limit: 1.
	^ result isEmpty
		ifTrue: [ nil ]
		ifFalse: [ result first ]
]

{ #category : #testing }
MaplessPostgresRepository >> hasDatabase [
	"Answers true if the database was already created."

	^ self
		withClientDo: [ :client | client hasDatabaseNamed: databaseName ]
]

{ #category : #testing }
MaplessPostgresRepository >> hasTableFor: aMaplessClass [
	^ self withClientDo: [ :client | client hasTableFor: aMaplessClass ]
]

{ #category : #accessing }
MaplessPostgresRepository >> idPropertyName [
	^ self class idPropertyName
]

{ #category : #initialization }
MaplessPostgresRepository >> initializeOn: aDatabaseName with: aDatabaseAccessor using: aMaplessResolver [
	super
		initializeOn: aDatabaseName
		with: aDatabaseAccessor
		using: aMaplessResolver.
	aDatabaseAccessor databaseName: aDatabaseName
]

{ #category : #actions }
MaplessPostgresRepository >> insert: aMapless [
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
MaplessPostgresRepository >> maplessDataPropertyName [
	^ self class maplessDataPropertyName
]

{ #category : #actions }
MaplessPostgresRepository >> normalizeIdOfOn: aJsonObject [
self halt.
	"aJsonObject at: 'id' put: (aJsonObject at: self idPropertyName).
	aJsonObject removeKey: self idPropertyName ifAbsent: [ nil ].
	^ aJsonObject"
]

{ #category : #reactions }
MaplessPostgresRepository >> onBeforeInsert: aMapless [
	self flag: #review. "not supported at the moment"
	aMapless ensurePrivateId.
	super onBeforeInsert: aMapless
]

{ #category : #actions }
MaplessPostgresRepository >> save: aMapless [
	"Storage this instance into the persistent collection.
	It will insert or update accordingly."

	self onBeforeSave: aMapless.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
	self onAfterSave: aMapless
]

{ #category : #actions }
MaplessPostgresRepository >> update: aMapless [
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
MaplessPostgresRepository >> withClientDo: aBlock [
	"Performs aBlock and providing access to the postgres client as aBlock argument."

	^ accessor withClientDo: aBlock
]

{ #category : #actions }
MaplessPostgresRepository >> withNormalizedId: aValue [
	^ UUID newFrom: aValue 
]
