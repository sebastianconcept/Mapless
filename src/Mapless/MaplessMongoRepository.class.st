"
A MaplessMongoRepository is a connection layer between Mapless and the mongo database. Use it using 

(MaplessMongoRepository on: aMongoDatabase) do: [ 
	
	""your stuff here""
	 ]





"
Class {
	#name : #MaplessMongoRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-Repositories'
}

{ #category : #actions }
MaplessMongoRepository class >> databaseNamed: aDatabaseName [
	"Returns the database found at aDatabaseName"
	
	^ MongoPool instance databaseAt: aDatabaseName 
]

{ #category : #accessing }
MaplessMongoRepository >> databaseCollectionNamed: aCollectionName [
	"Answers the collection for this kind of models hold by the current database"

	^ self database collectionAt: aCollectionName
]

{ #category : #actions }
MaplessMongoRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"

	| bsonFriendly filter |
	
	self onBeforeDestroy: aMapless.

	filter := JsonObject new 
					at: aMapless class idAttribute 
					put: (aMapless data at: aMapless class idAttribute); 
					yourself. 
		
	bsonFriendly := self storableFor: filter.
		
	(self databaseCollectionNamed: aMapless class collectionName) remove: bsonFriendly.
	
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessMongoRepository >> do: aBlock [
	"Performs aBlock and provides access to the database to 
	anyone calling CurrentMongoDatabase value."

	MaplessCurrentRepository
		value: self
		during: [ 
			MongoPool instance do: [ :mongoClient | ^ aBlock value ] ]
]

{ #category : #actions }
MaplessMongoRepository >> ensureCollection [
	self shouldBeImplemented.
]

{ #category : #testing }
MaplessMongoRepository >> existsId: anId of: aMaplessClass [

	^ ( self instanceOf: aMaplessClass  atId:  anId ) notNil
]

{ #category : #accessing }
MaplessMongoRepository >> idAttribute [
	"Answers '_id' because we're using MongoDB here 
	and that's what Mongo uses as id."

	^ '_id'
]

{ #category : #actions }
MaplessMongoRepository >> insert: aMapless [
	
	| bsonFriendly |

	self onBeforeInsert: aMapless.

	[ bsonFriendly := (self storableFor: aMapless data) ] ifCurtailed: [
		aMapless data removeKey: self idAttribute ifAbsent: [ nil ] ] .

	(self databaseCollectionNamed: aMapless class collectionName) add: bsonFriendly. 

	self onAfterInsert: aMapless

]

{ #category : #accessing }
MaplessMongoRepository >> instanceOf: aMaplessClass atId: anId [

	^self  
		instanceOf: aMaplessClass 
		where: (Dictionary newFromPairs: {self idAttribute. anId})
]

{ #category : #accessing }
MaplessMongoRepository >> instanceOf: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result databaseCollection |

	databaseCollection := self databaseCollectionNamed: aMaplessClass collectionName.
	result :=  databaseCollection queryOne: [ :q | q where: someConditions ].

	^result isNil
		ifTrue: [ nil ]
		ifFalse: [ self onAfterRead: (aMaplessClass fromJSONObject: result asJsonObject)  ]
]

{ #category : #accessing }
MaplessMongoRepository >> instancesOf: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^self instancesOf: aMaplessClass where: someConditions limit: nil offset: nil
]

{ #category : #accessing }
MaplessMongoRepository >> instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^self instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: nil
]

{ #category : #accessing }
MaplessMongoRepository >> instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	| result databaseCollection |

	databaseCollection := self databaseCollectionNamed: aMaplessClass collectionName.
	result := databaseCollection query:[:q | 
		aLimitOrNil ifNotNil: [ :limit | q limit: limit ].
		anOffsetOrNil ifNotNil: [ :offset | q offset: offset ].
		q where: someConditions].
	^(result isNil and:[result isEmpty])
		ifTrue: [ #() ]
		ifFalse: [ (aMaplessClass fromJSONObjects: result) collect: [ :each | self onAfterRead: each ] ]
]

{ #category : #reactions }
MaplessMongoRepository >> onBeforeInsert: aMapless [

	aMapless ensureId.

	super onBeforeInsert: aMapless
]

{ #category : #actions }
MaplessMongoRepository >> save: aMapless [
	"Storage this instance into the persistent collection"

	self onBeforeSave: aMapless.
	
	(self isUnsaved: aMapless)
		ifTrue: [ self insert: aMapless ]
		ifFalse: [ self update: aMapless ].

	self onAfterSave: aMapless
]

{ #category : #actions }
MaplessMongoRepository >> update: aMapless [

	| bsonFriendly |

	self onBeforeUpdate: aMapless.
	
	bsonFriendly := self storableFor: aMapless data.

	(self databaseCollectionNamed: aMapless class collectionName)
		replace:  (Dictionary new 
					at: self idAttribute put: (self idOf: aMapless);
					yourself)
		with: bsonFriendly.
		
	self onAfterUpdate: aMapless
]
