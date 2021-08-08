Class {
	#name : #MaplessPostgresRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-Repositories'
}

{ #category : #actions }
MaplessPostgresRepository class >> databaseNamed: aDatabaseName [
	"Returns the database found at aDatabaseName"
	
	"Currently we are using Postgres in single database mode.
	Which database is going to use is controlled by the Postgres configuration file."
	^ MaplessPostgresPool instance 
]

{ #category : #actions }
MaplessPostgresRepository >> addCollection: aCollectionName [

	^ database do: [ :pg |
		pg execute: 'CREATE TABLE "',aCollectionName,'" (
			key varchar(36) PRIMARY KEY, 
			value json);' ]
]

{ #category : #actions }
MaplessPostgresRepository >> basicDestroy: aBSONFriendlyObject [

	^ database do: [ :pg | | result |
		result := pg execute: 'DELETE FROM "',(aBSONFriendlyObject modelClass),'" * WHERE
				"key" = ''',aBSONFriendlyObject key,''';' ]
]

{ #category : #actions }
MaplessPostgresRepository >> basicInsert: aBSONFriendlyObject [

	^ database do: [ :pg | | result |
		result := pg execute: 'INSERT INTO "',(aBSONFriendlyObject modelClass),'" VALUES (
			''',aBSONFriendlyObject key,''',
			''',aBSONFriendlyObject asJSONString,''');' ]
]

{ #category : #actions }
MaplessPostgresRepository >> basicUpdate: aBSONFriendlyObject [

	^ database do: [ :pg | | result |
		result := pg execute: 'UPDATE "',(aBSONFriendlyObject modelClass),'" SET 
			"value" = ''',aBSONFriendlyObject asJSONString,''' WHERE
				"key" = ''',aBSONFriendlyObject key,''';' ]
]

{ #category : #actions }
MaplessPostgresRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"
	
	self onBeforeDestroy: aMapless.
		
	self basicDestroy: (self storableFor: aMapless data).
	
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessPostgresRepository >> ensureCollection [

	self shouldBeImplemented
]

{ #category : #testing }
MaplessPostgresRepository >> existsId: anId of: aMaplessClass [

	^ ( self instanceOf: aMaplessClass  atId:  anId ) notNil
]

{ #category : #testing }
MaplessPostgresRepository >> hasCollectionNamed: aCollectionName [
	"Answers true if a table named aCollectionName exists in the postgres database.
	False otherwise."
	
	^ database do: [ :pg | | result |
		result := pg execute: 'SELECT EXISTS (
			SELECT * FROM pg_tables WHERE
	tablename = ''',aCollectionName,''');'.

		result rows notEmpty and: [ 
		result rows first data first ] ]
]

{ #category : #accessing }
MaplessPostgresRepository >> idAttribute [
	"Answers'key' because we're using Postgres here 
	and that's what we want Postgres to use as id."

	^ 'key'
]

{ #category : #actions }
MaplessPostgresRepository >> insert: aMapless [
	
	| bsonFriendly |

	self onBeforeInsert: aMapless.

	[ bsonFriendly := (self storableFor: aMapless data) ] ifCurtailed: [
		aMapless data removeKey: self idAttribute ifAbsent: [ nil ] ].

	self ensureCollectionNamed: aMapless class name asString.
	self basicInsert: bsonFriendly. 

	self onAfterInsert: aMapless

]

{ #category : #accessing }
MaplessPostgresRepository >> instanceOf: aMapless atId: anId [

	^ self  
		instanceOf: aMapless 
		where: (self idAttribute, ' = ''', anId, '''')
]

{ #category : #accessing }
MaplessPostgresRepository >> instanceOf: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |

	result :=  self instancesOf: aMaplessClass where: someConditions.

	^ result isEmpty
		ifTrue: [ nil ]
		ifFalse: [ result first ]
]

{ #category : #accessing }
MaplessPostgresRepository >> instancesOf: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self instancesOf: aMaplessClass where: someConditions limit: nil offset: nil
]

{ #category : #accessing }
MaplessPostgresRepository >> instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: nil
]

{ #category : #accessing }
MaplessPostgresRepository >> instancesOf: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."
				
	^ database do: [ :pg | | result |
		result := pg execute: 'SELECT VALUE FROM "',
			(aMaplessClass name),'" WHERE ',someConditions,';'.
			
		(result isNil or: [ 
		result resultSets isEmpty ])
			ifTrue: [ #() ]
			ifFalse: [ result resultSets first rows collect: [ :row | | json |
						json := Json readFrom: row data first readStream.
						self onAfterRead: (aMaplessClass fromJSONObject: json)] ] ]
]

{ #category : #reactions }
MaplessPostgresRepository >> onBeforeInsert: aMapless [

	aMapless ensureId.

	super onBeforeInsert: aMapless
]

{ #category : #actions }
MaplessPostgresRepository >> save: aMapless [
	"Storage this instance into the persistent collection"

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
