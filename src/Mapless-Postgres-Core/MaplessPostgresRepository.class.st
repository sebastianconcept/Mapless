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

{ #category : #actions }
MaplessPostgresRepository >> addCollection: aCollectionName [
	^ database
		do: [ :pg | 
			pg
				execute:
					'CREATE TABLE "' , aCollectionName
						,
							'" (
			key varchar(36) PRIMARY KEY, 
			value json);' ]
]

{ #category : #actions }
MaplessPostgresRepository >> basicDestroy: aBSONFriendlyObject [
	^ database
		do: [ :pg | 
			| result |
			result := pg
				execute:
					'DELETE FROM "' , aBSONFriendlyObject modelClass
						,
							'" * WHERE
				"key" = ''' , aBSONFriendlyObject key , ''';' ]
]

{ #category : #actions }
MaplessPostgresRepository >> basicInsert: aBSONFriendlyObject as: aMaplessClass [
	self
		withClientDo: [ :client | client insert: aBSONFriendlyObject as: aMaplessClass ]
]

{ #category : #actions }
MaplessPostgresRepository >> basicUpdate: aBSONFriendlyObject [
	^ database
		do: [ :pg | 
			| result |
			result := pg
				execute:
					'UPDATE "' , aBSONFriendlyObject modelClass
						,
							'" SET 
			"value" = ''' , aBSONFriendlyObject asJSONString
						,
							''' WHERE
				"key" = ''' , aBSONFriendlyObject key , ''';' ]
]

{ #category : #actions }
MaplessPostgresRepository >> createDatabase [
	self
		withClientDo: [ :client | client createDatabaseNamed: databaseName ]
]

{ #category : #actions }
MaplessPostgresRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"

	self onBeforeDestroy: aMapless.
	self basicDestroy: (self storableFor: aMapless data).
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
	^ (self findOne: aMaplessClass atId: anId) notNil
]

{ #category : #accessing }
MaplessPostgresRepository >> findAll: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: nil
		offset: nil
]

{ #category : #accessing }
MaplessPostgresRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: nil
]

{ #category : #accessing }
MaplessPostgresRepository >> findAll: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ database
		do: [ :pg | 
			| result |
			result := pg
				execute:
					'SELECT VALUE FROM "' , aMaplessClass name , '" WHERE '
						, someConditions , ';'.
			(result isNil or: [ result resultSets isEmpty ])
				ifTrue: [ #() ]
				ifFalse: [ result resultSets first rows
						collect: [ :row | 
							| json |
							json := Json readFrom: row data first readStream.
							self onAfterRead: (aMaplessClass fromJSONObject: json) ] ] ]
]

{ #category : #accessing }
MaplessPostgresRepository >> findOne: aMapless atId: anId [
	^ self
		findOne: aMapless
		where: self idPropertyName , ' = ''' , anId , ''''
]

{ #category : #accessing }
MaplessPostgresRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |
	result := self findAll: aMaplessClass where: someConditions.
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
	^ MaplessPostgresClient idPropertyName
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
	^ MaplessPostgresClient maplessDataPropertyName
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
	self onBeforeUpdate: aMapless.
	self basicUpdate: (self storableFor: aMapless data).
	self onAfterUpdate: aMapless
]

{ #category : #actions }
MaplessPostgresRepository >> withClientDo: aBlock [
	"Performs aBlock and providing access to the postgres client as aBlock argument."

	^ accessor withClientDo: aBlock
]
