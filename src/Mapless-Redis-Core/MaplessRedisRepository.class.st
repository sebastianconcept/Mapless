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

{ #category : #testing }
MaplessRedisRepository >> existsId: anId of: aMaplessClass [
	^ accessor redis includesKey: anId
]

{ #category : #actions }
MaplessRedisRepository >> expires: aMapless in: seconds [
	accessor redis expire: (self idOf: aMapless) in: seconds
]

{ #category : #accessing }
MaplessRedisRepository >> find: aMaplessClass where: keysPattern [
	"Answer a collection of instances of aMaplessClass that have keys matching the given conditions."

	| values |
	values := accessor redis valuesAtKeys: keysPattern.
	^ values collect:[:each|
		self makeMapless: aMaplessClass fromValue: each ]
]

{ #category : #accessing }
MaplessRedisRepository >> findAll: aMaplessClass [
	^ self find: aMaplessClass where: aMaplessClass name, ':id:*'
]

{ #category : #accessing }
MaplessRedisRepository >> findOne: aMaplessClass atId: anId [
	| value |
	value := accessor redis at: anId.
	^ value
		ifNil: [ nil ]
		ifNotNil: [ self makeMapless: aMaplessClass fromValue: value with: anId ]
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
MaplessRedisRepository >> idOf: aMapless [
	| basicId |
	basicId := super idOf: aMapless.
	^ aMapless class name , ':id:' , basicId
]

{ #category : #accessing }
MaplessRedisRepository >> idPropertyName [
	"Answers'key' because we're using Postgres here 
	and that's what we want Postgres to use as id."

	^ 'id'
]

{ #category : #actions }
MaplessRedisRepository >> insert: aMapless [
	self onBeforeInsert: aMapless.
	self save: aMapless.
	self onAfterInsert: aMapless
]

{ #category : #actions }
MaplessRedisRepository >> makeMapless: aMaplessClass fromValue: storedValue [
	^ aMaplessClass fromBSONByteArray: storedValue asByteArray in: self
]

{ #category : #actions }
MaplessRedisRepository >> makeMapless: aMaplessClass fromValue: storedValue with: anId [
	^ (aMaplessClass fromBSONByteArray: storedValue asByteArray in: self)
		id: anId;
		yourself
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
	self save: aMapless.
	self onAfterUpdate: aMapless
]
