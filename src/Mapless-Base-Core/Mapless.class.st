"
Flow models are meant to be treated as aggregates.

We don't care here about identity.

Why?

Because the idea is that you keep these objects small and uncomplicated enough to be more efficienty serialized/deserialized in JSON for using it is some sort of noSQL persistence support.
"
Class {
	#name : #Mapless,
	#superclass : #Object,
	#instVars : [
		'data'
	],
	#category : #'Mapless-Base-Core-Models'
}

{ #category : #accessing }
Mapless class >> collection [
	^ self getRepository database collectionAt: self collectionName
]

{ #category : #configuration }
Mapless class >> collectionName [
	"Answers the collection name that is expected to be used by the concrete repository"

	^ name asString
]

{ #category : #querying }
Mapless class >> count [
	"Answer what's the number of instances of the receiver in the repository."

	^ self getRepository count: self
]

{ #category : #querying }
Mapless class >> count: someConditions [
	"Answer the integer number of instances of the receiver that meet someConditions in the repository."

	^ self getRepository count: self where: someConditions
]

{ #category : #accessing }
Mapless class >> currentRepository [
	^ MaplessCurrentRepository value
]

{ #category : #testing }
Mapless class >> existsId: anId [
	^ self getRepository existsId: anId of: self
]

{ #category : #querying }
Mapless class >> find: someConditions [
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^ self getRepository findAll: self where: someConditions
]

{ #category : #querying }
Mapless class >> find: someConditions limit: toHowManyResults [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: toHowManyResults
]

{ #category : #querying }
Mapless class >> find: someConditions limit: howManyResults offset: startingFromWhichResult [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: howManyResults
		offset: startingFromWhichResult
]

{ #category : #querying }
Mapless class >> find: someConditions limit: howManyResults offset: startingFromWhichResult sort: sortConditions [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: howManyResults
		offset: startingFromWhichResult
		sort: sortConditions
]

{ #category : #querying }
Mapless class >> find: someConditions limit: toHowManyResults sort: sortConditions [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: toHowManyResults
		sort: sortConditions
]

{ #category : #querying }
Mapless class >> find: someConditions sort: sortConditions [
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^ self getRepository
		findAll: self
		where: someConditions
		sort: sortConditions
]

{ #category : #querying }
Mapless class >> findAll [
	"Answer a collection with all receiver instances from the repository."

	^ self getRepository findAll: self
]

{ #category : #querying }
Mapless class >> findAllSort: sortConditions [
	^ self getRepository findAll: self sort: sortConditions
]

{ #category : #querying }
Mapless class >> findId: anId [
	^ self getRepository findOne: self atId: anId
]

{ #category : #querying }
Mapless class >> findOne: someConditions [
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^ self getRepository findOne: self where: someConditions
]

{ #category : #querying }
Mapless class >> first [
	^ self getRepository findOne: self where: Dictionary new
]

{ #category : #'instance creation' }
Mapless class >> fromBSONByteArray: aByteArray in: aMaplessRepository [
	| deserialized |
	deserialized := OrderedJsonObject
		fromAssociations: (BSON read: aByteArray readStream) associations.
	^ self fromJSONObject: deserialized in: aMaplessRepository
]

{ #category : #'instance creation' }
Mapless class >> fromJSONObject: aJsonObjectOrNilOrArray in: aMaplessRepository [
	aJsonObjectOrNilOrArray ifNil: [ ^ nil ].
	aJsonObjectOrNilOrArray isArray
		ifTrue: [ ^ self
				fromJSONObjects: aJsonObjectOrNilOrArray
				with: aMaplessRepository ].
	^ (aMaplessRepository maplessClassFor: aJsonObjectOrNilOrArray)
		basicNew
		initializeOn: (aJsonObjectOrNilOrArray asJsonObjectIn: aMaplessRepository)
			with: aMaplessRepository;
		yourself
]

{ #category : #'instance creation' }
Mapless class >> fromJSONObjects: someJsonObjects with: aRepository [
	^ someJsonObjects
		collect: [ :e | self fromJSONObject: e in: aRepository ]
]

{ #category : #'instance creation' }
Mapless class >> fromJSONString: aJsonString [
	^ self fromJSONString: aJsonString in: self getRepository
]

{ #category : #'instance creation' }
Mapless class >> fromJSONString: aJsonString in: aMaplessRepository [
	^ self
		fromJSONObject: (OrderedJson readFrom: aJsonString readStream)
		in: aMaplessRepository
]

{ #category : #accessing }
Mapless class >> getRepository [
	^ self currentRepository
]

{ #category : #configuration }
Mapless class >> idPropertyName [
	"For itself, Mapless uses 'id' as the property name for its main key."

	^ 'id'
]

{ #category : #testing }
Mapless class >> isAbstract [
	"Answers true if the model class is abstract.
	Very useful to subclassify a family of model classes 
	of which wouldn't make sense to create instances.

	You can (sub) implement where nessesary in an abstract model like this:
	
	^ self == AnAbstractModelClass"

	^ false
]

{ #category : #testing }
Mapless class >> isDeprecated [
	"Answers true if the model class is deprecated.
	Very useful for migrations after design changes.

	You can (sub) implement something like this in a deprecated class:
	
	^ self == DeprecatedModelClass"

	^ false
]

{ #category : #configuration }
Mapless class >> keysToExclude [
	"Answers the names of the keys that should be ignored 
	during some operations (like copying for example)"

	^ #('_id' 'id' 'v')
]

{ #category : #accessing }
Mapless class >> maplessClassName [
	^ self name
]

{ #category : #accessing }
Mapless class >> modelClasses [
	"Answers the set of classes which are concrete model classes.
	Note: deprecated or abstract ones are going to be excluded"

	^ self withAllSubclasses
		reject: [ :aClass | aClass isAbstract or: [ aClass isDeprecated ] ]
]

{ #category : #printing }
Mapless class >> pluralName [
	"Answers the string expected in a nicely designed API.
	Any subclass can override its own custom name.
	The default plural name is the singular name 
	in lower case plus an 's' so beware of irregular nouns."

	^ self singularName , 's'
]

{ #category : #printing }
Mapless class >> singularName [
	"Answers the string expected in a nicely designed API.
	Any subclass can override its own custom name.
	The default name is the class name in lowercase."

	^ self name asLowercase
]

{ #category : #testing }
Mapless >> = aModel [
	"Answers true if this model is meant to be the same as aModel.

	Note: as you can see by the implementation, this:
	1. won't care about in-image identity
	2. will do care about in-database identity 
	3. is not the right method if you want to compare 
	the contained information with the one in aModel."

	^ aModel class = self class and: [ self id = aModel id ]
]

{ #category : #converting }
Mapless >> asDictionary [
	"Answers this instance as a JSON friendly dictionary"

	^ [ :dic | 
	| attributes |
	attributes := OrderedJsonObject new.
	dic at: self class name asString put: attributes.
	self data
		associationsDo: [ :assoc | 
			assoc value isMapless
				ifTrue: [ attributes at: assoc key put: assoc value asDictionary ]
				ifFalse: [ attributes at: assoc key put: assoc value ] ].
	dic ] value: OrderedJsonObject new
]

{ #category : #converting }
Mapless >> asJSONString [
	self onBeforeJSON.
	^ super asJSONString
]

{ #category : #actions }
Mapless >> asMaplessReference [
	^ MaplessReference for: self
]

{ #category : #actions }
Mapless >> asMaplessReferenceIn: aMaplessRepository [
	^ MaplessReference for: self in: aMaplessRepository
]

{ #category : #accessing }
Mapless >> at: aKey [
	^ self data at: aKey
]

{ #category : #accessing }
Mapless >> at: aKey ifAbsent: aBlock [
	^ self data at: aKey ifAbsent: aBlock
]

{ #category : #actions }
Mapless >> at: aKey put: anObject [
	^ self data at: aKey put: anObject
]

{ #category : #accessing }
Mapless >> basicMaplessData [
	^ self data
]

{ #category : #converting }
Mapless >> basicMaplessId [
	^ self maplessData at: self class idPropertyName
]

{ #category : #actions }
Mapless >> beDeleted [
	self deletedOn: DateAndTime now
]

{ #category : #actions }
Mapless >> copyFrom: aMapless [
	"Takes the keys and values from aMapless
	and puts them in the local one.
	All key/values except for those to exclude 
	and without removing any local element."

	(aMapless data keys asOrderedCollection
		removeAllFoundIn: self class keysToExclude;
		yourself) do: [ :k | self data at: k put: (aMapless at: k) ]
]

{ #category : #accessing }
Mapless >> createdOn [
	| selector expects object |
	selector := #createdOn.
	expects := DateAndTime.
	object := self at: selector asString.
	(object isNil or: [ object isDictionary and: [ object isEmpty ] ])
		ifTrue: [ ^ nil ].
	(object isKindOf: expects)
		ifTrue: [ ^ object ].
	^ self at: selector asString put: (self dateAndTimeAt: selector)
]

{ #category : #accessing }
Mapless >> data [
	^ data ifNil: [ self initializeData ]
]

{ #category : #accessing }
Mapless >> data: aJsonObject [
	data := aJsonObject
]

{ #category : #actions }
Mapless >> dateAndTimeAt: aSelector [
	| value |
	value := self at: aSelector.
	value isString
		ifTrue: [ ^ DateAndTime fromString: value ].
	value isDictionary
		ifTrue: [ ^ DateAndTime fromUnixTime: (value at: '$date') / 1000 ].
	^ nil
]

{ #category : #actions }
Mapless >> delete [
	"Saves this instance as deleted in the persistent collection"

	self getRepository delete: self
]

{ #category : #actions }
Mapless >> destroy [
	"Removes this instance from the persistent collection"

	self getRepository destroy: self
]

{ #category : #accessing }
Mapless >> doesNotUnderstand: aMessage [
	"The idea behind this DNU is to use the selector as setters or getter 
	delegating to data (aJsonObject)"

	| key |
	key := aMessage selector.
	key isUnary
		ifTrue: [ ^ self data at: key asString ].
	^ (key isKeyword and: [ (key occurrencesOf: $:) = 1 ])
		ifTrue: [ key := key allButLast asSymbol.
			self data at: key asString put: aMessage arguments first.
			self ]
		ifFalse: [ super doesNotUnderstand: aMessage ]
]

{ #category : #actions }
Mapless >> fresh [
	^ self hasId
		ifFalse: [ self ]
		ifTrue: [ self class findId: self id ]
]

{ #category : #convenience }
Mapless >> getRepository [
	^ self class getRepository
]

{ #category : #testing }
Mapless >> hasId [
	^ self maplessData includesKey: 'id'
]

{ #category : #accessing }
Mapless >> id [
	"Answers the server-side assigned id of this mapless.
	Note: the expectation is to have this id set when is saved/inserted 
	for the first time into a repo."

	^ self maplessData at: 'id'
]

{ #category : #accessing }
Mapless >> id: anId [
	^ self maplessData at: 'id' put: anId
]

{ #category : #initializing }
Mapless >> initialize [
	super initialize.
	self initializeData
]

{ #category : #initializing }
Mapless >> initializeData [
	data := OrderedJsonObject new
		_c: self class maplessClassName;
		yourself
]

{ #category : #initializing }
Mapless >> initializeOn: aJsonObject with: aMaplessRepository [
	super initialize.
	data := aJsonObject.
	self setSubModelReferencesIn: aMaplessRepository.
	self setSubModelsIn: aMaplessRepository
]

{ #category : #actions }
Mapless >> insert [
	"Insert this instance into the persistent collection"

	self getRepository insert: self
]

{ #category : #testing }
Mapless >> isDeleted [
	^ self data includesKey: 'deletedOn'
]

{ #category : #testing }
Mapless >> isMapless [
	^ true
]

{ #category : #json }
Mapless >> jsonWriteOn: aStream [
	self maplessData jsonWriteOn: aStream
]

{ #category : #accessing }
Mapless >> maplessClass [
	^ self class
]

{ #category : #accessing }
Mapless >> maplessClassName [
	^ self class maplessClassName
]

{ #category : #accessing }
Mapless >> maplessData [
	"Returns the data part of a Mapless document.
	By default it is the data object, but subclasses might extend or change this."

	^ self basicMaplessData
]

{ #category : #converting }
Mapless >> maplessId [
	^ self basicMaplessId
]

{ #category : #actions }
Mapless >> merge: aMapless [
	"Merge the contents of this mapless instance with the contents in aMapless.
	It will NOT resolve merge conflicts or anything smart.
	It's just adding the missing parts.
	It does it deep, though."

	(aMapless maplessData keys asOrderedCollection
		removeAllFoundIn: aMapless class keysToExclude;
		yourself)
		do: [ :aKey | 
			| part |
			part := aMapless perform: aKey asSymbol.
			(part isKindOf: Mapless)
				ifTrue: [ | subMaplessOrNil |
					subMaplessOrNil := self perform: aKey asSymbol.
					subMaplessOrNil ifNotNil: [ subMaplessOrNil merge: part ] ].
			self maplessData at: aKey ifAbsentPut: [ part ] ]
]

{ #category : #hooks }
Mapless >> onAfterDelete [
	"At this point, the mapless was deleted.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onAfterDestroy [
	"This mapless was just destroyed at the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onAfterDestroyed [
	"This mapless was saved by the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onAfterInsert [
	"This mapless was inserted.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onAfterRead [
	"This mapless was just read from the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onAfterSave [
	
]

{ #category : #hooks }
Mapless >> onAfterSaved [
	"This mapless was saved by the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onAfterUpdate [
	"This mapless was updated.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onAfterUpsert [
	"This mapless was either inserted or updated.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onBeforeDelete [
	"This mapless is about to be deleted (intended to be marked as deleted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onBeforeDestroy [
	"This mapless is about to be destroyed (intended to be permanently removed from the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
Mapless >> onBeforeInsert [
	"This mapless is about to be inserted (intended to be added to the repo for the first time).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

]

{ #category : #hooks }
Mapless >> onBeforeJSON [
	"This model is about to be stringified in JSON.
	All inst var values that are expected to be model objects, need to be instanciated as expected."

	
]

{ #category : #hooks }
Mapless >> onBeforeSave [
	"This mapless is about to be saved (intended to get its current state persisted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	self modifiedOn: DateAndTime now
]

{ #category : #hooks }
Mapless >> onBeforeUpdate [
	"This mapless is about to be updated (intended to get its current state persisted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	self modifiedOn: DateAndTime now
]

{ #category : #hooks }
Mapless >> onBeforeUpsert [
	"This mapless is about to be upserted (intended to be added to the repo either for 
	the first time or updating the stored version).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #actions }
Mapless >> sanitize: someFields [
	"Removes someFields from the receiver."

	someFields do: [ :key | self data removeKey: key ifAbsent: [ nil ] ]
]

{ #category : #actions }
Mapless >> save [
	"Storage this instance into the persistent collection"

	self getRepository save: self
]

{ #category : #actions }
Mapless >> setReferenceFrom: aJsonObject on: aKey of: parentJsonObject in: aMaplessRepository [
	parentJsonObject
		at: aKey
		put: (MaplessReference fromJSONObject: aJsonObject in: aMaplessRepository)
]

{ #category : #actions }
Mapless >> setReferencesFrom: someJsonObjects on: aKey of: parentJsonObject in: aMaplessRepository [
	parentJsonObject
		at: aKey
		put:
			(someJsonObjects
				collect:
					[ :jsonObject | MaplessReference fromJSONObject: jsonObject in: aMaplessRepository ])
]

{ #category : #actions }
Mapless >> setSubModelReferencesAt: aKey with: anObject in: aMaplessRepository [
	"1. It's a submodel"

	(aMaplessRepository canRepresentSubMapless: anObject)
		ifTrue: [ ^ self
				setReferenceFrom: (JsonObject fromAssociations: anObject associations)
				on: aKey
				of: self data asJsonObject
				in: aMaplessRepository ].

	"2. it's a collection of submodels"
	(anObject isCollection
		and: [ anObject notEmpty
				and: [ anObject
						anySatisfy: [ :e | aMaplessRepository canRepresentSubMapless: e ] ] ])
		ifTrue: [ self
				setReferencesFrom: anObject
				on: aKey
				of: self data
				in: aMaplessRepository ]
]

{ #category : #actions }
Mapless >> setSubModelReferencesIn: aMaplessRepository [
	"Creates proxies to sub models regarding 
	to the JSON data this instance."

	self maplessData
		keysAndValuesDo:
			[ :k :v | self setSubModelReferencesAt: k with: v in: aMaplessRepository ]
]

{ #category : #actions }
Mapless >> setSubModelsAt: aKey with: anObject in: aMaplessRepository [
	"one submapless"

	| maplessClass newSubMapless className |
	(aMaplessRepository canBeMapless: anObject)
		ifTrue: [ className := anObject at: '_c'.
			maplessClass := Smalltalk
				at: className asSymbol
				ifAbsent: [ MaplessClassNotFound
						signal: ('The {1} class was not found in this image' format: {className}) ].
			newSubMapless := maplessClass
				fromJSONObject: anObject
				in: aMaplessRepository.
			newSubMapless setSubModelsIn: aMaplessRepository.
			self data at: aKey put: newSubMapless ].

	"many submapless"
	((anObject isCollection and: [ anObject isString not ])
		and: [ anObject anySatisfy: [ :e | aMaplessRepository canBeMapless: e ] ])
		ifTrue: [ | subMapless |
			subMapless := anObject
				collect: [ :each | 
					className := anObject at: '_c'.
					maplessClass := Smalltalk
						at: className asSymbol
						ifAbsent: [ MaplessClassNotFound
								signal: ('The {1} class was not found in this image' format: {className}) ].
					newSubMapless := maplessClass
						fromJSONObject: each
						in: aMaplessRepository.
					newSubMapless setSubModelsIn: aMaplessRepository ].
			self data at: aKey put: subMapless ]
]

{ #category : #actions }
Mapless >> setSubModelsIn: aMaplessRepository [
	"On demand creates sub models regarding 
	to the JSON data this instance."

	self data
		keysAndValuesDo: [ :k :v | self setSubModelsAt: k with: v in: aMaplessRepository ]
]

{ #category : #actions }
Mapless >> unreferenced [
	"Returns this model without references to submodels.
	It will reify any proxy (reference to another sub model) found"

	self data
		keysAndValuesDo: [ :k :v | 
			v class = MaplessReference
				ifTrue: [ | subModel |
					subModel := v model.
					self data at: k put: subModel unreferenced ].
			"decend one level into arrays which could hold MaplessMongoReference's"
			v isArray
				ifTrue: [ | unreferencedCollection |
					unreferencedCollection := OrderedCollection new.
					v
						do: [ :each | 
							each class = MaplessReference
								ifFalse: [ unreferencedCollection add: each unreferenced ]
								ifTrue: [ | subModelInArray |
									subModelInArray := each model.
									unreferencedCollection add: subModelInArray unreferenced ] ].
					self data at: k put: unreferencedCollection ] ]
]

{ #category : #actions }
Mapless >> update [
	self getRepository update: self
]

{ #category : #actions }
Mapless >> upsert [
	"Storage this instance into the persistent collection"

	self getRepository upsert: self
]
