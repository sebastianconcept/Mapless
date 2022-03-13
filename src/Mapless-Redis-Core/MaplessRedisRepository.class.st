Class {
	#name : #MaplessRedisRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-Redis-Core-Connections'
}

{ #category : #actions }
MaplessRedisRepository class >> getNewId [
	^ UUID new asString36
]

{ #category : #actions }
MaplessRedisRepository >> auth: aPassword [
	accessor auth: aPassword.
	self setDatabase: databaseName
]

{ #category : #actions }
MaplessRedisRepository >> basicDestroy: aBSONFriendlyObject [
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
MaplessRedisRepository >> basicInsert: aBSONFriendlyObject [
	^ database
		do: [ :pg | 
			| result |
			result := pg
				execute:
					'INSERT INTO "' , aBSONFriendlyObject modelClass
						,
							'" VALUES (
			''' , aBSONFriendlyObject key
						,
							''',
			''' , aBSONFriendlyObject asJSONString , ''');' ]
]

{ #category : #actions }
MaplessRedisRepository >> basicUpdate: aBSONFriendlyObject [
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
MaplessRedisRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"

	self onBeforeDestroy: aMapless.
	accessor redis deleteKey: aMapless id.
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessRedisRepository >> drop [
	^ accessor drop
]

{ #category : #actions }
MaplessRedisRepository >> ensureCollection [
	self shouldBeImplemented
]

{ #category : #testing }
MaplessRedisRepository >> existsId: anId of: aMaplessClass [
	^ (self findOne: aMaplessClass atId: anId) notNil
]

{ #category : #accessing }
MaplessRedisRepository >> find: aMaplessClass where: someConditions [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditions
		limit: nil
		offset: nil
]

{ #category : #accessing }
MaplessRedisRepository >> find: aMaplessClass where: someConditions limit: aLimitOrNil [
	"Answer a collection of instances of aMaplessClass that meet with someConditions from the repository."

	^ self
		find: aMaplessClass
		where: someConditions
		limit: aLimitOrNil
		offset: nil
]

{ #category : #accessing }
MaplessRedisRepository >> find: aMaplessClass where: someConditions limit: aLimitOrNil offset: anOffsetOrNil [
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
MaplessRedisRepository >> findOne: aMaplessClass atId: anId [
	| value |
	value := accessor redis at: anId.
	^ value
		ifNil: [ nil ]
		ifNotNil: [ (aMaplessClass fromBSONByteArray: value asByteArray in: self)
				id: anId;
				yourself ]
]

{ #category : #accessing }
MaplessRedisRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |
	result := self find: aMaplessClass where: someConditions.
	^ result isEmpty
		ifTrue: [ nil ]
		ifFalse: [ result first ]
]

{ #category : #accessing }
MaplessRedisRepository >> idPropertyName [
	"Answers'key' because we're using Postgres here 
	and that's what we want Postgres to use as id."

	^ 'id'
]

{ #category : #actions }
MaplessRedisRepository >> insert: aMapless [
	| bsonFriendly |
	self onBeforeInsert: aMapless.
	[ bsonFriendly := self storableFor: aMapless data ]
		ifCurtailed: [ aMapless data removeKey: self idPropertyName ifAbsent: [ nil ] ].
	self ensureCollectionNamed: aMapless class name asString.
	self basicInsert: bsonFriendly.
	self onAfterInsert: aMapless
]

{ #category : #reactions }
MaplessRedisRepository >> onBeforeSave: aMapless [
	self ensureIdOf: aMapless.
	super onBeforeSave: aMapless
]

{ #category : #actions }
MaplessRedisRepository >> save: aMapless [
	| key storable serialized |
	self onBeforeSave: aMapless.
	key := self idOf: aMapless.
	storable := resolver storableFor: aMapless in: self.
	serialized := BSON write: storable.
	accessor redis at: key put: serialized.
	self onAfterSave: aMapless
]

{ #category : #actions }
MaplessRedisRepository >> setDatabase: aZeroBasedDbIndex [
	accessor setDatabase: aZeroBasedDbIndex
]

{ #category : #actions }
MaplessRedisRepository >> update: aMapless [
	self onBeforeUpdate: aMapless.
	self basicUpdate: (self storableFor: aMapless data).
	self onAfterUpdate: aMapless
]
