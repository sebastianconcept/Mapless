"
A MaplessMongoRepository is a connection layer between Mapless and the mongo database. Use it using 




"
Class {
	#name : #MaplessMongoRepository,
	#superclass : #MaplessRepository,
	#instVars : [
		'mongoClient',
		'concerns',
		'defaultConcerns'
	],
	#category : #'Mapless-Mongo-Core-Connections'
}

{ #category : #actions }
MaplessMongoRepository class >> getNewId [
	^ OID nextOID
]

{ #category : #accessing }
MaplessMongoRepository >> concerns [
	^ concerns ifNil: [ self initializeConcerns ]
]

{ #category : #accessing }
MaplessMongoRepository >> count: aMaplessClass [
	"Answer what's the number of instances of aMaplessClass in this repository."

	^ self count: aMaplessClass where: {} asDictionary
]

{ #category : #accessing }
MaplessMongoRepository >> count: aMaplessClass where: someConditions [
	"Answer what's the number of instances of aMaplessClass in this repository."

	^ self
		readOnlyDo: [ (self databaseCollectionNamed: aMaplessClass collectionName)
				sizeForQuery: someConditions ]
]

{ #category : #accessing }
MaplessMongoRepository >> database [
	^ mongoClient databaseNamed: databaseName
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
	"Removes aMapless from the persistent collection"

	self
		destroy: aMapless
		writeConcern: (self deleteConcernFor: aMapless class)
]

{ #category : #actions }
MaplessMongoRepository >> destroy: aMapless writeConcern: aConcernOrNil [
	"Removes aMapless from the persistent collection"

	| filter |
	self onBeforeDestroy: aMapless.
	filter := JsonObject new
		at: self idPropertyName put: aMapless id;
		yourself.
	self
		readWriteDo: [ (self databaseCollectionNamed: aMapless class collectionName)
				commandDelete: filter
				limit: 1
				writeConcern: aConcernOrNil ].
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessMongoRepository >> do: aBlock [
	^ self do: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> do: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client in use during this thread to 
	anyone calling MaplessCurrentRepository value."

	aDatabaseAccessor
		readWriteDo: [ :client | 
			[ mongoClient := client.
			MaplessCurrentRepository value: self during: [ ^ aBlock value ] ]
				ensure: [ mongoClient := nil ] ]
]

{ #category : #accessing }
MaplessMongoRepository >> drop [
	^ self readWriteDo: [ self database drop ]
]

{ #category : #actions }
MaplessMongoRepository >> ensureCollection [
	self shouldBeImplemented
]

{ #category : #testing }
MaplessMongoRepository >> existsId: anId of: aMaplessClass [
	^ (self
		count: aMaplessClass
		where: {(self idPropertyName -> anId)} asDictionary) > 0
]

{ #category : #accessing }
MaplessMongoRepository >> find: aMaplessClass where: someConditionsOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		find: aMaplessClass
		where: someConditionsOrNil
		limit: nil
		offset: nil
]

{ #category : #accessing }
MaplessMongoRepository >> find: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		find: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: nil
]

{ #category : #accessing }
MaplessMongoRepository >> find: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		find: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: anOffsetOrNil
		sort: nil
]

{ #category : #accessing }
MaplessMongoRepository >> find: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil offset: anOffsetOrNil sort: sortConditionsOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

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
	^ self
		readOnlyDo: [ cursor := self newCursorFor: command.
			(aMaplessClass
				fromJSONObjects:
					(cursor
						collect: [ :each | self normalizeIdOfOn: (each asJsonObjectIn: self) ])
				with: self) collect: [ :each | self onAfterRead: each ] ]
]

{ #category : #accessing }
MaplessMongoRepository >> find: aMaplessClass where: someConditionsOrNil limit: aLimitOrNil sort: sortConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditionsOrNil from the repository."

	^ self
		find: aMaplessClass
		where: someConditionsOrNil
		limit: aLimitOrNil
		offset: nil
		sort: sortConditions
]

{ #category : #accessing }
MaplessMongoRepository >> find: aMaplessClass where: someConditionsOrNil sort: sortConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditionsOrNil
		limit: nil
		offset: nil
		sort: sortConditions
]

{ #category : #accessing }
MaplessMongoRepository >> findAll: aMaplessClass [
	^ self find: aMaplessClass where: nil
]

{ #category : #accessing }
MaplessMongoRepository >> findAll: aMaplessClass sort: sortConditions [
	^ self find: aMaplessClass where: nil sort: sortConditions
]

{ #category : #accessing }
MaplessMongoRepository >> findOne: aMaplessClass atId: anId [
	^ self
		findOne: aMaplessClass
		where:
			(Dictionary
				newFromPairs:
					{self idPropertyName.
					anId})
]

{ #category : #accessing }
MaplessMongoRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| found |
	found := self
		find: aMaplessClass
		where: someConditions
		limit: 1
		offset: 0
		sort: nil.
	^ found isEmpty
		ifTrue: [ nil ]
		ifFalse: [ found first ]
]

{ #category : #testing }
MaplessMongoRepository >> hasMongoClient [
	^ mongoClient notNil
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
		at: #insert put: Dictionary new;
		at: #upsert put: Dictionary new;
		at: #update put: Dictionary new;
		at: #delete put: Dictionary new;
		yourself
]

{ #category : #initialization }
MaplessMongoRepository >> initializeDefaultConcerns [
	^ defaultConcerns := Dictionary new
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
	| bsonFriendly |
	self onBeforeInsert: aMapless.
	bsonFriendly := resolver storableFor: aMapless in: self.
	self
		readWriteDo: [ (self databaseCollectionNamed: aMapless class collectionName)
				commandInsert: bsonFriendly
				writeConcern: aConcernOrNil ].
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

{ #category : #accessing }
MaplessMongoRepository >> mongoClient [
	^ mongoClient
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
MaplessMongoRepository >> readOnlyDo: aBlock [
	^ self readOnlyDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> readOnlyDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client in use during this thread to 
	anyone calling MaplessCurrentRepository value."

	aDatabaseAccessor
		readOnlyDo: [ :client | 
			[ mongoClient := client.
			MaplessCurrentRepository value: self during: [ ^ aBlock value ] ]
				ensure: [ mongoClient := nil ] ]
]

{ #category : #actions }
MaplessMongoRepository >> readWriteDo: aBlock [
	^ self readWriteDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> readWriteDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client in use during this thread to 
	anyone calling MaplessCurrentRepository value."

	aDatabaseAccessor
		readWriteDo: [ :client | 
			[ mongoClient := client.
			MaplessCurrentRepository value: self during: [ ^ aBlock value ] ]
				ensure: [ mongoClient := nil ] ]
]

{ #category : #actions }
MaplessMongoRepository >> save: aMapless [
	"Storage this instance into the persistent collection"

	self
		save: aMapless
		writeConcern: (self upsertConcernFor: aMapless class)
]

{ #category : #actions }
MaplessMongoRepository >> save: aMapless writeConcern: aConcernOrNil [
	"Storage this instance into the persistent collection"

	self onBeforeSave: aMapless.
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless writeConcern: aConcernOrNil ]
		ifFalse: [ self update: aMapless writeConcern: aConcernOrNil ].
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
	self onBeforeUpdate: aMapless.
	self upsert: aMapless writeConcern: aConcernOrNil.
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
	| bsonFriendly |
	self onBeforeUpsert: aMapless.
	bsonFriendly := resolver storableFor: aMapless in: self.
	self
		readWriteDo: [ self database
				commandUpsert:
					(Dictionary new
						at: self idPropertyName put: (self idOf: aMapless);
						yourself)
				with: bsonFriendly
				collection: aMapless class collectionName
				writeConcern: aConcernOrNil ].
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
MaplessMongoRepository >> withReadOnlyClientDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client as aBlock argument."

	aDatabaseAccessor
		readOnlyDo: [ :client | 
			[ mongoClient := client.
			MaplessCurrentRepository
				value: self
				during: [ ^ aBlock value: client ] ]
				ensure: [ mongoClient := nil ] ]
]

{ #category : #actions }
MaplessMongoRepository >> withReadWriteClientDo: aBlock [
	^ self withReadWriteClientDo: aBlock with: accessor
]

{ #category : #actions }
MaplessMongoRepository >> withReadWriteClientDo: aBlock with: aDatabaseAccessor [
	"Performs aBlock and providing access to the mongo client as aBlock argument."

	aDatabaseAccessor
		readWriteDo: [ :client | 
			[ mongoClient := client.
			MaplessCurrentRepository
				value: self
				during: [ ^ aBlock value: client ] ]
				ensure: [ mongoClient := nil ] ]
]

{ #category : #actions }
MaplessMongoRepository >> withReadnlyClientDo: aBlock [
	^ self withReadOnlyClientDo: aBlock with: accessor
]
