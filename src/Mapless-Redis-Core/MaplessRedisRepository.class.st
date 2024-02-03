"
I support Mapless features using Redis
"
Class {
	#name : #MaplessRedisRepository,
	#superclass : #MaplessRepository,
	#category : #'Mapless-Redis-Core-Core'
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

{ #category : #accessing }
MaplessRedisRepository >> channelNameFor: aMapless when: anEventSelector [

	"Answers the channel name to use for messaging occurrences 
	of anEventSelector about the given mapless object, aMapless.
	The channel name is formatted as '{1}:{2}', where:
	- {1} is the id of the mapless object, aMapless.
	- {2} is the string representation of anEventSelector."

	^ '{1}:{2}' format: { 
			  aMapless id asString.
			  anEventSelector asString }
]

{ #category : #accessing }
MaplessRedisRepository >> count: aMaplessClass [
	^ self count: aMaplessClass where: aMaplessClass name , ':id:*'
]

{ #category : #accessing }
MaplessRedisRepository >> count: aMaplessClass where: keyPattern [
	"KEYS and the much preferred SCAN are both 'evil'.
	Doing KEYS (or SCAN) in real time is very expensive 
	in terms of performance - it means that you're iterating over the entire keyspace."

	^ (accessor redis keys: keyPattern) size
]

{ #category : #actions }
MaplessRedisRepository >> destroy: aMapless [
	"Removes aMapless from the persistent collection"

	self onBeforeDestroy: aMapless.
	accessor redis deleteKey: (self namespacedIdOf: aMapless).
	self onAfterDestroy: aMapless
]

{ #category : #actions }
MaplessRedisRepository >> drop [
	^ accessor drop
]

{ #category : #testing }
MaplessRedisRepository >> existsId: anId of: aMaplessClass [
	^ accessor redis
		includesKey: (self namespacedIdOf: aMaplessClass valued: anId)
]

{ #category : #actions }
MaplessRedisRepository >> expires: aMapless in: millisecondsValue [
	^ accessor redis endpoint
		expire: (self namespacedIdOf: aMapless)
		at: DateAndTime now + (Duration milliSeconds: millisecondsValue)
]

{ #category : #accessing }
MaplessRedisRepository >> findAll: aMaplessClass [
	^ self findAll: aMaplessClass where: aMaplessClass name, ':id:*'
]

{ #category : #accessing }
MaplessRedisRepository >> findAll: aMaplessClass where: keysPattern [
	"Answer a collection of instances of aMaplessClass that have keys matching the given conditions."

	| keys pairs found all |
	keys := accessor redis keys: keysPattern.
	pairs := Dictionary new.
	all := OrderedCollection new.
	keys
		do: [ :key | 
			found := accessor redis at: key.
			found ifNotNil: [ pairs at: key put: found ] ].
	pairs
		keysAndValuesDo: [ :key :value | 
			all
				add:
					((self makeMapless: aMaplessClass fromValue: value)
						id: (self unnamespaced: 'id' in: key);
						yourself) ].
	^ all
]

{ #category : #accessing }
MaplessRedisRepository >> findOne: aMaplessClass atId: anId [
	| value |
	value := accessor redis
		at: (self namespaced: 'id' of: aMaplessClass valued: anId).
	^ value
		ifNil: [ nil ]
		ifNotNil: [ self makeMapless: aMaplessClass fromValue: value with: anId ]
]

{ #category : #accessing }
MaplessRedisRepository >> findOne: aMaplessClass where: someConditions [
	"Answer one instance of aMaplessClass that meet with someConditions from the repository."

	| result |
	result := self findAll: aMaplessClass where: someConditions.
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

{ #category : #accessing }
MaplessRedisRepository >> namespaced: propertyName of: aMapless [
	^ '{1}:{2}:{3}'
		format:
			{aMapless maplessClassName.
			propertyName.
			(aMapless data at: propertyName)}
]

{ #category : #accessing }
MaplessRedisRepository >> namespaced: propertyName of: aMaplessClass valued: aValue [
	^ '{1}:{2}:{3}'
		format:
			{aMaplessClass name.
			propertyName.
			aValue}
]

{ #category : #accessing }
MaplessRedisRepository >> namespacedIdOf: aMapless [
	^ self namespaced: 'id' of: aMapless
]

{ #category : #accessing }
MaplessRedisRepository >> namespacedIdOf: aMaplessClass valued: aValue [
	^ self namespaced: 'id' of: aMaplessClass valued: aValue
]

{ #category : #actions }
MaplessRedisRepository >> normalizeIdOfOn: aJsonObject [
	"No need to normalize it"
]

{ #category : #reactions }
MaplessRedisRepository >> onBeforeSave: aMapless [
	self ensureIdOf: aMapless.
	super onBeforeSave: aMapless
]

{ #category : #actions }
MaplessRedisRepository >> publish: anEventSelector from: aMapless [

	(self isUnsaved: aMapless) ifTrue: [ 
		MaplessObserverOnUnsaved signal:
			'Mapless objects need to be saved for publishing events.' ].

	accessor
		publish: (self channelNameFor: aMapless when: anEventSelector)
		message: anEventSelector
]

{ #category : #actions }
MaplessRedisRepository >> removeExpireFor: aMapless [
	^ accessor redis endpoint persist: (self namespacedIdOf: aMapless)
]

{ #category : #actions }
MaplessRedisRepository >> save: aMapless [
	| key storable serialized |
	self onBeforeSave: aMapless.
	key := self namespacedIdOf: aMapless.
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
MaplessRedisRepository >> subscribe: aMapless when: anEventSelector evaluate: anAction [

	"Subscribes the provided action, anAction, to be evaluated whenever 
	an event with the specified anEventSelector occurs about the given 
	mapless object, aMapless.

	Example:
		maplessRedisRepository 
			subscribe: someMaplessObject 
			when: #updated 
			evaluate: [ :event | self handleUpdateEvent: event ]"

	"Verify only saved Mapless subscribe to pubsub channels"

	(self isUnsaved: aMapless) ifTrue: [ 
		MaplessObserverOnUnsaved signal:
			'Cannot observe an unsaved mapless object' ].

	"Wire reacting with anAction so triggered events are handled"
	aMapless when: #pubsubPublished evaluate: anAction.

	"Subscribe to the right channel for anEventSelector"
	accessor
		subscribe: (self channelNameFor: aMapless when: anEventSelector)
		callback: [ :pubsubResponse | 
			pubsubResponse payload ifNotNil: [ 
				aMapless triggerEvent: #pubsubPublished ] ]
]

{ #category : #actions }
MaplessRedisRepository >> ttlFor: aMapless [
	^ accessor redis endpoint pttl: (self namespacedIdOf: aMapless)
]

{ #category : #accessing }
MaplessRedisRepository >> unnamespaced: propertyName in: aNamespacedKey [
	^ aNamespacedKey readStream
		upTo: propertyName;
		upTo: $:;
		upToEnd
]

{ #category : #actions }
MaplessRedisRepository >> unsubscribe: aMapless from: anEventSelector [

	"Unsubscribe from the right channel for anEventSelector on aMapless"
	accessor unsubscribe:
		(self channelNameFor: aMapless when: anEventSelector).

	"Local unwiring of attempts to react to it"
	aMapless removeActionsForEvent: #pubsubPublished
]

{ #category : #actions }
MaplessRedisRepository >> update: aMapless [
	self onBeforeUpdate: aMapless.
	self save: aMapless.
	self onAfterUpdate: aMapless
]
