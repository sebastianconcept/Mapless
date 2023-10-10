"
I give access to SQLite
"
Class {
	#name : #MaplessSQLiteRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-SQLite-Core'
}

{ #category : #actions }
MaplessSQLiteRepository class >> getNewId [
	^ UUID new asString36
]

{ #category : #accessing }
MaplessSQLiteRepository class >> idPropertyName [
	"Answers 'id' and we're using it as Postgres 
	primary key for the Mapless table of any given Mapless class."

	^ 'id'
]

{ #category : #accessing }
MaplessSQLiteRepository class >> maplessDataPropertyName [
	"Answers'maplessData' as the column name 
	where we're going to use the Postgres JSON blob."

	^ 'maplessData'
]

{ #category : #actions }
MaplessSQLiteRepository >> basicInsert: serializableObject as: aMaplessClass [
	self
		withClientDo:
			[ :client | client insert: serializableObject as: aMaplessClass in: self ]
]

{ #category : #actions }
MaplessSQLiteRepository >> basicUpdate: aBSONFriendlyObject as: aMaplessClass [
	self
		withClientDo:
			[ :client | client update: aBSONFriendlyObject as: aMaplessClass in: self ]
]

{ #category : #querying }
MaplessSQLiteRepository >> count: aMaplessClass [
	^ self count: aMaplessClass where: nil
]

{ #category : #querying }
MaplessSQLiteRepository >> count: aMaplessClass where: conditions [
	^ self
		withClientDo: [ :client | client count: aMaplessClass where: conditions in: self ]
]

{ #category : #actions }
MaplessSQLiteRepository >> createDatabase [
	self
		withClientDo: [ :client | client createDatabaseNamed: databaseName ]
]

{ #category : #actions }
MaplessSQLiteRepository >> delete: aMapless [
	self onBeforeDelete: aMapless.
	aMapless deletedOn: DateAndTime now.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
	self onAfterDelete: aMapless
]

{ #category : #actions }
MaplessSQLiteRepository >> destroy: aMapless [
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
MaplessSQLiteRepository >> destroyAll: aMaplessClass [
	self withClientDo: [ :client | client truncate: aMaplessClass ]
]

{ #category : #actions }
MaplessSQLiteRepository >> destroyAll: aMaplessClass where: condition [
	self
		withClientDo: [ :client | client destroyAll: aMaplessClass where: condition ]
]

{ #category : #actions }
MaplessSQLiteRepository >> dropDatabase [
	self
		withClientDo: [ :client | client dropDatabaseNamed: databaseName ]
]

{ #category : #actions }
MaplessSQLiteRepository >> ensureCollection [
	self shouldBeImplemented
]

{ #category : #actions }
MaplessSQLiteRepository >> ensureDatabase [
	
]

{ #category : #actions }
MaplessSQLiteRepository >> ensureTableFor: aMaplessClass [
	self
		withClientDo: [ :client |
			(client hasTableFor: aMaplessClass)
				ifFalse: [ client createTableFor: aMaplessClass ] ]
]

{ #category : #testing }
MaplessSQLiteRepository >> existsId: anId of: aMaplessClass [
	^ (self
		count: aMaplessClass
		where:
			('{1} = ''{2}'''
				format:
					{self idPropertyName.
					anId})) > 0
]

{ #category : #querying }
MaplessSQLiteRepository >> findAll: aMaplessClass [

	^ self withClientDo: [ :client | 
		  self halt.
		  client findAll: aMaplessClass in: self ]
]

{ #category : #querying }
MaplessSQLiteRepository >> findAll: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: nil
		offset: nil
]

{ #category : #querying }
MaplessSQLiteRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: nil
]

{ #category : #querying }
MaplessSQLiteRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: nil
]

{ #category : #querying }
MaplessSQLiteRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [
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
MaplessSQLiteRepository >> findOne: aMapless atId: anId [
	^ self
		findOne: aMapless
		where:
			('{1} = ''{2}'''
				format:
					{self idPropertyName.
					anId})
]

{ #category : #querying }
MaplessSQLiteRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |
	result := self findAll: aMaplessClass where: someConditions limit: 1.
	^ result isEmpty
		ifTrue: [ nil ]
		ifFalse: [ result first ]
]

{ #category : #testing }
MaplessSQLiteRepository >> hasDatabase [
	"Answers true if the database was already created."

	^ self
		withClientDo: [ :client | client hasDatabaseNamed: databaseName ]
]

{ #category : #testing }
MaplessSQLiteRepository >> hasTableFor: aMaplessClass [
	^ self withClientDo: [ :client | client hasTableFor: aMaplessClass ]
]

{ #category : #accessing }
MaplessSQLiteRepository >> idPropertyName [
	^ self class idPropertyName
]

{ #category : #initialization }
MaplessSQLiteRepository >> initializeOn: aDatabaseName with: aDatabaseAccessor using: aMaplessResolver [
	super
		initializeOn: aDatabaseName
		with: aDatabaseAccessor
		using: aMaplessResolver.
	aDatabaseAccessor databaseName: aDatabaseName
]

{ #category : #actions }
MaplessSQLiteRepository >> insert: aMapless [
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
MaplessSQLiteRepository >> maplessDataPropertyName [
	^ self class maplessDataPropertyName
]

{ #category : #actions }
MaplessSQLiteRepository >> normalizeIdOfOn: aJsonObject [
	"No need to normalize it"
]

{ #category : #reactions }
MaplessSQLiteRepository >> onBeforeInsert: aMapless [
	self flag: #review. "not supported at the moment"
	aMapless ensurePrivateId.
	super onBeforeInsert: aMapless
]

{ #category : #actions }
MaplessSQLiteRepository >> save: aMapless [
	"Storage this instance into the persistent collection.
	It will insert or update accordingly."

	self onBeforeSave: aMapless.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
	self onAfterSave: aMapless
]

{ #category : #actions }
MaplessSQLiteRepository >> update: aMapless [
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
MaplessSQLiteRepository >> withClientDo: aBlock [
	"Performs aBlock and providing access to the postgres client as aBlock argument."

	^ accessor withClientDo: aBlock
]

{ #category : #actions }
MaplessSQLiteRepository >> withNormalizedId: aValue [

	^ aValue
]
