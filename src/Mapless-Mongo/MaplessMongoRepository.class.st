"
A MaplessMongoRepository is a connection layer between Mapless and the mongo database. Use it using 




"
Class {
	#name : #MaplessMongoRepository,
	#superclass : #MaplessRepository,
	#instVars : [
		'concerns',
		'defaultConcerns'
	],
	#category : #'Mapless-Mongo-Connections'
}

{ #category : #actions }
MaplessMongoRepository class >> getNewId [
	^ OID nextOID
]

{ #category : #accessing }
MaplessMongoRepository >> concerns [
	^ concerns ifNil: [ self initializeConcerns ]
]

{ #category : #querying }
MaplessMongoRepository >> count: aMaplessClass [
	"Answer what's the number of instances of aMaplessClass in this repository."

	^ self count: aMaplessClass where: {} asDictionary
]

{ #category : #querying }
MaplessMongoRepository >> count: aMaplessClass where: someConditions [
	"Answer what's the number of instances of aMaplessClass in this repository."

	^ self
		readOnlyDo: [ (self databaseCollectionNamed: aMaplessClass collectionName)
				sizeForQuery: someConditions ]
]

{ #category : #accessing }
MaplessMongoRepository >> database [
	^ MongoCurrentClient value databaseNamed: databaseName
]

{ #category : #accessing }
MaplessMongoRepository >> databaseCollectionNamed: aCollectionName [
	"Answers the collection for this kind of models hold by the current database"

	^ self database collectionAt: aCollectionName
]

{ #category : #accessing }
MaplessMongoRepository >> defaultConcerns [
	^ defaultConcerns ifNil: [ self initializeDefaultConcerns ]
]

{ #category : #accessing }
MaplessMongoRepository >> defaultDeleteConcern [
	^ self defaultConcerns at: #delete
]

{ #category : #accessing }
MaplessMongoRepository >> defaultDeleteConcern: aConcernOrNil [
	^ self defaultConcerns at: #delete put: aConcernOrNil
]

{ #category : #accessing }
MaplessMongoRepository >> defaultInsertConcern [
	^ self defaultConcerns at: #insert
]

{ #category : #accessing }
MaplessMongoRepository >> defaultInsertConcern: aConcernOrNil [
	^ self defaultConcerns at: #insert put: aConcernOrNil
]

{ #category : #accessing }
MaplessMongoRepository >> defaultReadConcern [
	^ self defaultConcerns at: #read
]

{ #category : #accessing }
MaplessMongoRepository >> defaultReadConcern: aConcernOrNil [
	^ self defaultConcerns at: #read put: aConcernOrNil
]

{ #category : #accessing }
MaplessMongoRepository >> defaultUpdateConcern [
	^ self defaultConcerns at: #update
]

{ #category : #accessing }
MaplessMongoRepository >> defaultUpdateConcern: aConcernOrNil [
	^ self defaultConcerns at: #update put: aConcernOrNil
]

{ #category : #accessing }
MaplessMongoRepository >> defaultUpsertConcern [
	^ self defaultConcerns at: #upsert
]

{ #category : #accessing }
MaplessMongoRepository >> defaultUpsertConcern: aConcernOrNil [
	^ self defaultConcerns at: #upsert put: aConcernOrNil
]

{ #category : #accessing }
MaplessMongoRepository >> deleteConcern: aConcern for: aMaplessClass [
	^ (self concerns at: #delete) at: aMaplessClass put: aConcern
]

{ #category : #accessing }
MaplessMongoRepository >> deleteConcernFor: aMaplessClass [
	^ (self concerns at: #delete)
		at: aMaplessClass
		ifPresent: [ :val | val ]
		ifAbsent: [ self defaultDeleteConcern ]
]

{ #category : #actions }
MaplessMongoRepository >> destroy: aMapless [
	"Removes aMapless from its corresponding collection."

	self
		destroy: aMapless
		writeConcern: (self deleteConcernFor: aMapless class)
]

{ #category : #actions }
MaplessMongoRepository >> destroy: aMapless writeConcern: aConcernOrNil [
	"Removes aMapless from its corresponding collection."

	| serializable |
	self onBeforeDestroy: aMapless.
	serializable := resolver storableFor: aMapless in: self.
	self
		readWriteDo: [ (self databaseCollectionNamed: aMapless class collectionName)
				commandDelete: {(self idPropertyName -> aMapless id)} asDictionary
				limit: 1
				writeConcern: aConcernOrNil.
			self
				triggerEvent: #maplessMongoDeleteOf:serializable:writeConcern:in:
				withArguments:
					{aMapless.
					serializable.
					aConcernOrNil.
					self} ].
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessMongoRepository >> destroyAll: aMaplessClass [
	"Remove all the documents matching the filter criteria from the MongoDB collection corresponding to aMaplessClass."

	^ self
		destroyAll: aMaplessClass
		where: {} asDictionary
		writeConcern: (self deleteConcernFor: aMaplessClass)
]

{ #category : #actions }
MaplessMongoRepository >> destroyAll: aMaplessClass where: filter [
	"Remove all the documents matching the filter criteria from the MongoDB collection corresponding to aMaplessClass."

	^ self
		destroyAll: aMaplessClass
		where: filter
		writeConcern: (self deleteConcernFor: aMaplessClass)
]

{ #category : #actions }
MaplessMongoRepository >> destroyAll: aMaplessClass where: filter writeConcern: aConcernOrNil [
	"Remove all the documents matching the filter criteria from the MongoDB collection corresponding to aMaplessClass."

	^ self
		readWriteDo: [ (self databaseCollectionNamed: aMaplessClass collectionName)
				commandDelete: filter
				limit: 0
				writeConcern: aConcernOrNil ]
]

{ #category : #actions }
MaplessMongoRepository >> destroyAll: aMaplessClass writeConcern: aWriteConcern [
	"Remove all the documents matching the filter criteria from the MongoDB collection corresponding to aMaplessClass."

	^ self
		destroyAll: aMaplessClass
		where: {} asDictionary
		writeConcern: aWriteConcern
]

{ #category : #actions }
MaplessMongoRepository >> destroyOne: aMaplessClass atId: anId [
	"Removes the document anId from the MongoDB collection corresponding to aMaplessClass."

	^ self
		destroyOne: aMaplessClass
		atId: anId
		writeConcern: (self deleteConcernFor: aMaplessClass)
]

{ #category : #actions }
MaplessMongoRepository >> destroyOne: aMaplessClass atId: anId writeConcern: aConcernOrNil [
	"Removes the document anId from the MongoDB collection corresponding to aMaplessClass."

	^ self
		readWriteDo: [ (self databaseCollectionNamed: aMaplessClass collectionName)
				commandDelete: {(self idPropertyName -> anId)} asDictionary
				limit: 1
				writeConcern: aConcernOrNil ]
]

{ #category : #actions }
MaplessMongoRepository >> do: aBlock [
	^ self do: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> do: aBlock with: aDatabaseAccessor [
	"Performs aBlock providing access to this repo to 
	anyone calling MaplessCurrentRepository value from this thread."

	aDatabaseAccessor
		readWriteDo:
			[ :client | MaplessCurrentRepository value: self during: [ ^ aBlock value ] ]
]

{ #category : #actions }
MaplessMongoRepository >> drop [
	^ self readWriteDo: [ self database drop ]
]

{ #category : #testing }
MaplessMongoRepository >> existsId: anId of: aMaplessClass [
	^ (self
		count: aMaplessClass
		where: {(self idPropertyName -> anId)} asDictionary) > 0
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass [
	^ self
		findAll: aMaplessClass
		where: (resolver conditionForClass: aMaplessClass)
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass readConcern: aMongoReadConcernOrNil [
	^ self
		findAll: aMaplessClass
		where: (resolver conditionForClass: aMaplessClass)
		readConcern: aMongoReadConcernOrNil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass sort: sortConditions [
	^ self
		findAll: aMaplessClass
		where: (resolver conditionForClass: aMaplessClass)
		sort: sortConditions
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass sort: sortConditions readConcern: aMongoReadConcernOrNil [
	^ self
		findAll: aMaplessClass
		where: (resolver conditionForClass: aMaplessClass)
		sort: sortConditions
		readConcern: aMongoReadConcernOrNil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: nil
		offset: nil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: nil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: nil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil readConcern: aMongoReadConcernOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: nil
		readConcern: aMongoReadConcernOrNil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: sortConditionsOrNil
		readConcern: (self readConcernFor: aMaplessClass)
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil readConcern: aMongoReadConcernOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository using the optional aMongoReadConcernOrNil."

	| command cursor |
	command := OrderedDictionary new
		at: 'find' put: aMaplessClass collectionName;
		yourself.
	someConditionsOrNil
		ifNotNil: [ :conditions | command at: 'filter' put: conditions asMongoQuery ].
	aLimitOrNil
		ifNotNil: [ :limit | command at: 'limit' put: aLimitOrNil ].
	anOffsetOrNil ifNotNil: [ :offset | command at: 'skip' put: offset ].
	sortConditionsOrNil
		ifNotNil: [ :sort | command at: 'sort' put: sort ].
	aMongoReadConcernOrNil
		ifNotNil: [ command
				at: 'readConcern'
				put: aMongoReadConcernOrNil concernForCommand ].
	^ self
		readOnlyDo: [ cursor := self newCursorFor: command.
			(aMaplessClass
				fromJSONObjects:
					(cursor
						collect: [ :each | self normalizeIdOfOn: (each asJsonObjectIn: self) ])
				with: self) collect: [ :each | self onAfterRead: each ] ]
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil readConcern: aMongoReadConcernOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: nil
		readConcern: aMongoReadConcernOrNil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil sort: sortConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: nil
		sort: sortConditions
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil readConcern: aMongoReadConcernOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: nil
		offset: nil
		readConcern: aMongoReadConcernOrNil
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil sort: sortConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: nil
		offset: nil
		sort: sortConditions
]

{ #category : #querying }
MaplessMongoRepository >> findAll: aMaplessClass where: someConditionsOrNil sort: sortConditions readConcern: aMongoReadConcernOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		findAll: aMaplessClass
		where: someConditionsOrNil
		limit: nil
		offset: nil
		sort: sortConditions
		readConcern: aMongoReadConcernOrNil
]

{ #category : #querying }
MaplessMongoRepository >> findOne: aMaplessClass atId: anId [
	^ self
		findOne: aMaplessClass
		where: {(self idPropertyName -> anId)} asDictionary
]

{ #category : #querying }
MaplessMongoRepository >> findOne: aMaplessClass atId: anId readConcern: aMongoReadConcernOrNil [
	^ self
		findOne: aMaplessClass
		where: {(self idPropertyName -> anId)} asDictionary
		readConcern: aMongoReadConcernOrNil
]

{ #category : #querying }
MaplessMongoRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| found |
	found := self
		findAll: aMaplessClass
		where: someConditions
		limit: 1
		offset: 0
		sort: nil.
	^ found isEmpty
		ifTrue: [ nil ]
		ifFalse: [ found first ]
]

{ #category : #querying }
MaplessMongoRepository >> findOne: aMaplessClass where: someConditions readConcern: aMongoReadConcernOrNil [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| found |
	found := self
		findAll: aMaplessClass
		where: someConditions
		limit: 1
		offset: 0
		sort: nil
		readConcern: aMongoReadConcernOrNil.
	^ found isEmpty
		ifTrue: [ nil ]
		ifFalse: [ found first ]
]

{ #category : #accessing }
MaplessMongoRepository >> idPropertyName [
	"Answers '_id' because we're using MongoDB here 
	and that's what Mongo uses as id."

	^ '_id'
]

{ #category : #initialization }
MaplessMongoRepository >> initializeConcerns [
	^ concerns := Dictionary new
		at: #read put: Dictionary new;
		at: #insert put: Dictionary new;
		at: #upsert put: Dictionary new;
		at: #update put: Dictionary new;
		at: #delete put: Dictionary new;
		yourself
]

{ #category : #initialization }
MaplessMongoRepository >> initializeDefaultConcerns [
	^ defaultConcerns := Dictionary new
		at: #read put: nil;
		at: #insert put: nil;
		at: #upsert put: nil;
		at: #update put: nil;
		at: #delete put: nil;
		yourself
]

{ #category : #actions }
MaplessMongoRepository >> insert: aMapless [
	self
		insert: aMapless
		writeConcern: (self insertConcernFor: aMapless class)
]

{ #category : #actions }
MaplessMongoRepository >> insert: aMapless writeConcern: aConcernOrNil [
	| serializable |
	self onBeforeInsert: aMapless.
	serializable := resolver storableFor: aMapless in: self.
	serializable
		at: self idPropertyName
		ifAbsent: [ serializable at: self idPropertyName put: self class getNewId ].
	self
		readWriteDo: [ (self databaseCollectionNamed: aMapless class collectionName)
				commandInsert: serializable
				writeConcern: aConcernOrNil.
			self
				triggerEvent: #maplessMongoInsertOf:serializable:writeConcern:in:
				withArguments:
					{aMapless.
					serializable.
					aConcernOrNil.
					self} ].
	self ensureId: (serializable at: self idPropertyName) for: aMapless.
	self onAfterInsert: aMapless
]

{ #category : #accessing }
MaplessMongoRepository >> insertConcern: aConcern for: aMaplessClass [
	^ (self concerns at: #insert) at: aMaplessClass put: aConcern
]

{ #category : #accessing }
MaplessMongoRepository >> insertConcernFor: aMaplessClass [
	^ (self concerns at: #insert)
		at: aMaplessClass
		ifPresent: [ :val | val ]
		ifAbsent: [ self defaultInsertConcern ]
]

{ #category : #actions }
MaplessMongoRepository >> newCursorFor: aDictionary [
	"Returns a new MongoCursor based on the current database and using aDictionary as command.
	We're making it able to read from secondaries by default in case this uses a 
	connection to a secondary node in a MongoDB cluster."

	^ (MongoCommandCursor database: self database dictionary: aDictionary)
		setFlagSlaveOk;
		yourself
]

{ #category : #actions }
MaplessMongoRepository >> normalizeIdOfOn: aJsonObject [
	aJsonObject at: 'id' put: (aJsonObject at: self idPropertyName).
	aJsonObject removeKey: self idPropertyName ifAbsent: [ nil ].
	^ aJsonObject
]

{ #category : #accessing }
MaplessMongoRepository >> readConcern: aConcern for: aMaplessClass [
	^ (self concerns at: #read) at: aMaplessClass put: aConcern
]

{ #category : #accessing }
MaplessMongoRepository >> readConcernFor: aMaplessClass [
	^ (self concerns at: #read)
		at: aMaplessClass
		ifPresent: [ :val | val ]
		ifAbsent: [ self defaultReadConcern ]
]

{ #category : #actions }
MaplessMongoRepository >> readOnlyDo: aBlock [
	^ self readOnlyDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> readOnlyDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock with a client that can read only.
	Also, provides access to this repo to anyone calling 
	MaplessCurrentRepository value from this thread."

	aDatabaseAccessor
		readOnlyDo:
			[ :client | MaplessCurrentRepository value: self during: [ ^ aBlock value ] ]
]

{ #category : #actions }
MaplessMongoRepository >> readWriteDo: aBlock [
	^ self readWriteDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> readWriteDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock with a client that can read and write.
	Also, provides access to this repo to anyone calling 
	MaplessCurrentRepository value from this thread."

	aDatabaseAccessor
		readWriteDo:
			[ :client | MaplessCurrentRepository value: self during: [ ^ aBlock value ] ]
]

{ #category : #actions }
MaplessMongoRepository >> save: aMapless [
	"Storage this instance into the persistent collection"

	self onBeforeSave: aMapless.
	(self isUnsaved: aMapless)
		ifTrue: [ self
				insert: aMapless
				writeConcern: (self insertConcernFor: aMapless class) ]
		ifFalse: [ self
				update: aMapless
				writeConcern: (self updateConcernFor: aMapless class) ].
	self onAfterSave: aMapless
]

{ #category : #actions }
MaplessMongoRepository >> update: aMapless [
	self
		update: aMapless
		writeConcern: (self updateConcernFor: aMapless class)
]

{ #category : #actions }
MaplessMongoRepository >> update: aMapless writeConcern: aConcernOrNil [
	| serializable |
	self onBeforeUpdate: aMapless.
	serializable := resolver storableFor: aMapless in: self.
	self
		readWriteDo: [ self database
				commandUpdate: {(self idPropertyName -> aMapless id)} asDictionary
				with: serializable
				collection: aMapless class collectionName
				writeConcern: aConcernOrNil.
			self
				triggerEvent: #maplessMongoUpdateOf:serializable:writeConcern:in:
				withArguments:
					{aMapless.
					serializable.
					aConcernOrNil.
					self} ].
	self onAfterUpdate: aMapless
]

{ #category : #accessing }
MaplessMongoRepository >> updateConcern: aConcern for: aMaplessClass [
	^ (self concerns at: #update) at: aMaplessClass put: aConcern
]

{ #category : #accessing }
MaplessMongoRepository >> updateConcernFor: aMaplessClass [
	^ (self concerns at: #update)
		at: aMaplessClass
		ifPresent: [ :val | val ]
		ifAbsent: [ self defaultUpdateConcern ]
]

{ #category : #actions }
MaplessMongoRepository >> upsert: aMapless [
	self
		upsert: aMapless
		writeConcern: (self upsertConcernFor: aMapless class)
]

{ #category : #actions }
MaplessMongoRepository >> upsert: aMapless writeConcern: aConcernOrNil [
	| bsonFriendly idValue |
	self onBeforeUpsert: aMapless.
	bsonFriendly := resolver storableFor: aMapless in: self.
	idValue := (self isUnsaved: aMapless)
		ifTrue: [ bsonFriendly at: self idPropertyName put: self class getNewId ]
		ifFalse: [ aMapless id ].
	self
		readWriteDo: [ self database
				commandUpsert: {(self idPropertyName -> idValue)} asDictionary
				with: bsonFriendly
				collection: aMapless class collectionName
				writeConcern: aConcernOrNil ].
	self ensureId: idValue for: aMapless.
	self onAfterUpsert: aMapless
]

{ #category : #accessing }
MaplessMongoRepository >> upsertConcern: aConcern for: aMaplessClass [
	^ (self concerns at: #upsert) at: aMaplessClass put: aConcern
]

{ #category : #accessing }
MaplessMongoRepository >> upsertConcernFor: aMaplessClass [
	^ (self concerns at: #upsert)
		at: aMaplessClass
		ifPresent: [ :val | val ]
		ifAbsent: [ self defaultUpsertConcern ]
]

{ #category : #actions }
MaplessMongoRepository >> withClientDo: aBlock [
	^ self withClientDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> withClientDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client as aBlock argument."

	^ self withReadWriteClientDo: aBlock with: aDatabaseAccessor
]

{ #category : #actions }
MaplessMongoRepository >> withReadOnlyClientDo: aBlock [
	^ self withReadOnlyClientDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> withReadOnlyClientDo: aBlock with: aDatabaseAccessor [
	aDatabaseAccessor
		readOnlyDo: [ :client | 
			MaplessCurrentRepository
				value: self
				during: [ ^ aBlock value: client ] ]
]

{ #category : #actions }
MaplessMongoRepository >> withReadWriteClientDo: aBlock [
	^ self withReadWriteClientDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> withReadWriteClientDo: aBlock with: aDatabaseAccessor [
	aDatabaseAccessor
		readWriteDo: [ :client | 
			MaplessCurrentRepository
				value: self
				during: [ ^ aBlock value: client ] ]
]
