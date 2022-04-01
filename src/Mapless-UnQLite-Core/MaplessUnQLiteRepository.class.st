Class {
	#name : #MaplessUnQLiteRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-UnQLite-Core-Core'
}

{ #category : #actions }
MaplessUnQLiteRepository class >> for: aFilePathString [
	^ self
		for: aFilePathString
		with: (MaplessUnQLitePool on: aFilePathString)
		using: MaplessCollectionToClassNameResolver new
]

{ #category : #actions }
MaplessUnQLiteRepository class >> getNewId [
	^ UUID new asString36
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

{ #category : #querying }
MaplessUnQLiteRepository >> basicFindOne: aMaplessClass atId: anId in: aMaplessRepository using: anUnQLiteClient [
	| result key |
	key := self namespaced: 'id' of: aMaplessClass valued: anId.
	result := anUnQLiteClient at: key ifAbsent: [ nil ].
	result ifNotNil: [ ^ self makeMaplessFrom: result withId: anId ].
	^ nil
]

{ #category : #actions }
MaplessUnQLiteRepository >> basicSave: aMapless [
	| key storable |
	key := self namespacedIdOf: aMapless.
	storable := resolver storableFor: aMapless in: self.
	self
		withClientDo: [ :client | client at: key put: (self serialize: storable) ].
	self onAfterSave: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> bsonDeserialize: aByteArray [
	^ self maplessFromResult: (BSON read: aByteArray readStream)
]

{ #category : #actions }
MaplessUnQLiteRepository >> bsonSerialize: aStorable [
	^ BSON write: aStorable
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
MaplessUnQLiteRepository >> delete: aMapless [
	self onBeforeDelete: aMapless.
	aMapless deletedOn: DateAndTime now.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].
	self onAfterDelete: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> deserialize: aByteArray [
	^ self bsonDeserialize: aByteArray
]

{ #category : #actions }
MaplessUnQLiteRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"

	| key |
	self onBeforeDestroy: aMapless.
	self
		withClientDo: [ :client | 
			key := self namespacedIdOf: aMapless.
			client removeKey: key ifAbsent: [ nil ] ].
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> destroyAll: aMaplessClass [
	self destroyAll: aMaplessClass where: '*'
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

{ #category : #testing }
MaplessUnQLiteRepository >> existsId: anId of: aMaplessClass [
	^ self
		withClientDo:
			[ :client | client includesKey: (self namespacedIdOf: aMaplessClass valued: anId) ]
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
MaplessUnQLiteRepository >> findOne: aMaplessClass atId: anId [
	^ self
		withClientDo: [ :client | 
			self
				basicFindOne: aMaplessClass
				atId: anId
				in: self
				using: client ]
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

{ #category : #actions }
MaplessUnQLiteRepository >> insert: aMapless [
	self onBeforeInsert: aMapless.
	self basicSave: aMapless.
	self onAfterInsert: aMapless
]

{ #category : #querying }
MaplessUnQLiteRepository >> makeMaplessFrom: aByteArray withId: anId [
	^ (self deserialize: aByteArray)
		id: anId;
		yourself
]

{ #category : #accessing }
MaplessUnQLiteRepository >> maplessDataPropertyName [
	^ self class maplessDataPropertyName
]

{ #category : #querying }
MaplessUnQLiteRepository >> maplessFromResult: aDictionarish [
	^ Mapless
		fromJSONObject: (JsonObject fromAssociations: aDictionarish associations)
		in: self
]

{ #category : #actions }
MaplessUnQLiteRepository >> messagePackedDeserialize: aByteArray [
	^ self maplessFromResult: (Object fromMessagePack: aByteArray)
]

{ #category : #actions }
MaplessUnQLiteRepository >> messagePackedSerialize: aStorable [
	^ aStorable asDictionary messagePacked
]

{ #category : #accessing }
MaplessUnQLiteRepository >> namespaced: propertyName of: aStorable [
	^ '{1}:{2}:{3}'
		format:
			{(aStorable at: '_c').
			propertyName.
			(aStorable at: propertyName)}
]

{ #category : #accessing }
MaplessUnQLiteRepository >> namespaced: propertyName of: aMaplessClass valued: aValue [
	^ '{1}:{2}:{3}'
		format:
			{aMaplessClass name.
			propertyName.
			aValue}
]

{ #category : #accessing }
MaplessUnQLiteRepository >> namespacedIdOf: aStorable [
	^ self namespaced: 'id' of: aStorable
]

{ #category : #accessing }
MaplessUnQLiteRepository >> namespacedIdOf: aMaplessClass valued: aValue [
	^ self namespaced: 'id' of: aMaplessClass valued: aValue
]

{ #category : #actions }
MaplessUnQLiteRepository >> normalizeIdOfOn: aJsonObject [
	"No need to normalize it"
]

{ #category : #reactions }
MaplessUnQLiteRepository >> onBeforeInsert: aMapless [
	self flag: #review. "not supported at the moment"
	aMapless ensurePrivateId.
	super onBeforeInsert: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> onBeforeSave: aMapless [
	self ensureIdOf: aMapless.
	super onBeforeSave: aMapless
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
MaplessUnQLiteRepository >> serialize: aStorable [
	^ self bsonSerialize: aStorable
]

{ #category : #actions }
MaplessUnQLiteRepository >> update: aMapless [
	self onBeforeUpdate: aMapless.
	self basicSave: aMapless.
	self onAfterUpdate: aMapless
]

{ #category : #actions }
MaplessUnQLiteRepository >> withClientDo: aBlock [
	"Performs aBlock and providing access to the postgres client as aBlock argument."

	^ accessor withClientDo: aBlock
]

{ #category : #actions }
MaplessUnQLiteRepository >> withNormalizedId: aValue [
	^ aValue 
]
