Trait {
	#name : #MaplessBehavior,
	#instVars : [
		'data'
	],
	#category : #'Mapless-Base-Core-Models'
}

{ #category : #accessing }
MaplessBehavior classSide >> collection [
	^ self getRepository database collectionAt: self collectionName
]

{ #category : #configuration }
MaplessBehavior classSide >> collectionName [
	"Answers the collection name that is expected to be used by the concrete repository"

	^ name asString
]

{ #category : #querying }
MaplessBehavior classSide >> count [
	"Answer what's the number of instances of the receiver in the repository."

	^ self getRepository count: self
]

{ #category : #querying }
MaplessBehavior classSide >> count: someConditions [
	"Answer the integer number of instances of the receiver that meet someConditions in the repository."

	^ self getRepository count: self where: someConditions
]

{ #category : #accessing }
MaplessBehavior classSide >> currentRepository [
	^ MaplessCurrentRepository value
]

{ #category : #testing }
MaplessBehavior classSide >> existsId: anId [
	^ self getRepository existsId: anId of: self
]

{ #category : #querying }
MaplessBehavior classSide >> find: someConditions [
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^ self getRepository findAll: self where: someConditions
]

{ #category : #querying }
MaplessBehavior classSide >> find: someConditions limit: toHowManyResults [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: toHowManyResults
]

{ #category : #querying }
MaplessBehavior classSide >> find: someConditions limit: howManyResults offset: startingFromWhichResult [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: howManyResults
		offset: startingFromWhichResult
]

{ #category : #querying }
MaplessBehavior classSide >> find: someConditions limit: howManyResults offset: startingFromWhichResult sort: sortConditions [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: howManyResults
		offset: startingFromWhichResult
		sort: sortConditions
]

{ #category : #querying }
MaplessBehavior classSide >> find: someConditions limit: toHowManyResults sort: sortConditions [
	^ self getRepository
		findAll: self
		where: someConditions
		limit: toHowManyResults
		sort: sortConditions
]

{ #category : #querying }
MaplessBehavior classSide >> find: someConditions sort: sortConditions [
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^ self getRepository
		findAll: self
		where: someConditions
		sort: sortConditions
]

{ #category : #querying }
MaplessBehavior classSide >> findAll [
	"Answer a collection with all receiver instances from the repository."

	^ self getRepository findAll: self
]

{ #category : #querying }
MaplessBehavior classSide >> findAllSort: sortConditions [
	^ self getRepository findAll: self sort: sortConditions
]

{ #category : #querying }
MaplessBehavior classSide >> findId: anId [
	^ self getRepository findOne: self atId: anId
]

{ #category : #querying }
MaplessBehavior classSide >> findOne: someConditions [
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^ self getRepository findOne: self where: someConditions
]

{ #category : #querying }
MaplessBehavior classSide >> first [
	^ self getRepository findOne: self where: Dictionary new
]

{ #category : #'instance creation' }
MaplessBehavior classSide >> fromBSONByteArray: aByteArray in: aMaplessRepository [
	| deserialized |
	deserialized := OrderedJsonObject
		fromAssociations: (BSON read: aByteArray readStream) associations.
	^ self fromJSONObject: deserialized in: aMaplessRepository
]

{ #category : #'instance creation' }
MaplessBehavior classSide >> fromJSONObject: aJsonObjectOrNilOrArray in: aMaplessRepository [
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
MaplessBehavior classSide >> fromJSONObjects: someJsonObjects with: aRepository [
	^ someJsonObjects
		collect: [ :e | self fromJSONObject: e in: aRepository ]
]

{ #category : #'instance creation' }
MaplessBehavior classSide >> fromJSONString: aJsonString [
	^ self fromJSONString: aJsonString in: self getRepository
]

{ #category : #'instance creation' }
MaplessBehavior classSide >> fromJSONString: aJsonString in: aMaplessRepository [
	^ self
		fromJSONObject: (OrderedJson readFrom: aJsonString readStream)
		in: aMaplessRepository
]

{ #category : #accessing }
MaplessBehavior classSide >> getRepository [
	^ self currentRepository
]

{ #category : #configuration }
MaplessBehavior classSide >> idPropertyName [
	"For itself, Mapless uses 'id' as the property name for its main key."

	^ 'id'
]

{ #category : #testing }
MaplessBehavior classSide >> isAbstract [
	"Answers true if the model class is abstract.
	Very useful to subclassify a family of model classes 
	of which wouldn't make sense to create instances.

	You can (sub) implement where nessesary in an abstract model like this:
	
	^ self == AnAbstractModelClass"

	^ false
]

{ #category : #testing }
MaplessBehavior classSide >> isDeprecated [
	"Answers true if the model class is deprecated.
	Very useful for migrations after design changes.

	You can (sub) implement something like this in a deprecated class:
	
	^ self == DeprecatedModelClass"

	^ false
]

{ #category : #configuration }
MaplessBehavior classSide >> keysToExclude [
	"Answers the names of the keys that should be ignored 
	during some operations (like copying for example)"

	^ #('_id' 'id' 'v')
]

{ #category : #accessing }
MaplessBehavior classSide >> maplessClass [
	^ self
]

{ #category : #accessing }
MaplessBehavior classSide >> maplessClassName [
	^ self name
]

{ #category : #accessing }
MaplessBehavior classSide >> modelClasses [
	"Answers the set of classes which are concrete model classes.
	Note: deprecated or abstract ones are going to be excluded"

	^ self withAllSubclasses
		reject: [ :aClass | aClass isAbstract or: [ aClass isDeprecated ] ]
]

{ #category : #printing }
MaplessBehavior classSide >> pluralName [
	"Answers the string expected in a nicely designed API.
	Any subclass can override its own custom name.
	The default plural name is the singular name 
	in lower case plus an 's' so beware of irregular nouns."

	^ self singularName , 's'
]

{ #category : #printing }
MaplessBehavior classSide >> singularName [
	"Answers the string expected in a nicely designed API.
	Any subclass can override its own custom name.
	The default name is the class name in lowercase."

	^ self name asLowercase
]

{ #category : #testing }
MaplessBehavior >> = aModel [
	"Answers true if this model is meant to be the same as aModel.

	Note: as you can see by the implementation, this:
	1. won't care about in-image identity
	2. will do care about in-database identity 
	3. is not the right method if you want to compare 
	the contained information with the one in aModel."

	^ aModel class = self class and: [ self id = aModel id ]
]

{ #category : #converting }
MaplessBehavior >> asDictionary [
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
MaplessBehavior >> asJSONString [
	self onBeforeJSON.
	^ super asJSONString
]

{ #category : #actions }
MaplessBehavior >> asMaplessReference [
	^ MaplessReference for: self
]

{ #category : #actions }
MaplessBehavior >> asMaplessReferenceIn: aMaplessRepository [
	^ MaplessReference for: self in: aMaplessRepository
]

{ #category : #accessing }
MaplessBehavior >> at: aKey [
	^ self data at: aKey
]

{ #category : #accessing }
MaplessBehavior >> at: aKey ifAbsent: aBlock [
	^ self data at: aKey ifAbsent: aBlock
]

{ #category : #actions }
MaplessBehavior >> at: aKey put: anObject [
	^ self data at: aKey put: anObject
]

{ #category : #accessing }
MaplessBehavior >> basicMaplessData [
	^ self data
]

{ #category : #converting }
MaplessBehavior >> basicMaplessId [
	^ self maplessData at: self class idPropertyName
]

{ #category : #actions }
MaplessBehavior >> beDeleted [
	self deletedOn: DateAndTime now
]

{ #category : #actions }
MaplessBehavior >> copyFrom: aMapless [
	"Takes the keys and values from aMapless
	and puts them in the local one.
	All key/values except for those to exclude 
	and without removing any local element."

	(aMapless data keys asOrderedCollection
		removeAllFoundIn: self class keysToExclude;
		yourself) do: [ :k | self data at: k put: (aMapless at: k) ]
]

{ #category : #accessing }
MaplessBehavior >> createdOn [
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
MaplessBehavior >> data [
	^ data ifNil: [ self initializeData ]
]

{ #category : #accessing }
MaplessBehavior >> data: aJsonObject [
	data := aJsonObject
]

{ #category : #actions }
MaplessBehavior >> dateAndTimeAt: aSelector [
	| value |
	value := self at: aSelector.
	value isString
		ifTrue: [ ^ DateAndTime fromString: value ].
	value isDictionary
		ifTrue: [ ^ DateAndTime fromUnixTime: (value at: '$date') / 1000 ].
	^ nil
]

{ #category : #actions }
MaplessBehavior >> delete [
	"Saves this instance as deleted in the persistent collection"

	self getRepository delete: self
]

{ #category : #actions }
MaplessBehavior >> destroy [
	"Removes this instance from the persistent collection"

	self getRepository destroy: self
]

{ #category : #accessing }
MaplessBehavior >> doesNotUnderstand: aMessage [
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
MaplessBehavior >> fresh [
	^ self hasId
		ifFalse: [ self ]
		ifTrue: [ self class findId: self id ]
]

{ #category : #convenience }
MaplessBehavior >> getRepository [
	^ self class getRepository
]

{ #category : #testing }
MaplessBehavior >> hasId [
	^ self maplessData includesKey: 'id'
]

{ #category : #accessing }
MaplessBehavior >> id [
	"Answers the server-side assigned id of this mapless.
	Note: the expectation is to have this id set when is saved/inserted 
	for the first time into a repo."

	^ self maplessData at: 'id'
]

{ #category : #accessing }
MaplessBehavior >> id: anId [
	^ self maplessData at: 'id' put: anId
]

{ #category : #initializing }
MaplessBehavior >> initialize [
	super initialize.
	self initializeData
]

{ #category : #initializing }
MaplessBehavior >> initializeData [
	data := OrderedJsonObject new
		_c: self class maplessClassName;
		yourself
]

{ #category : #initializing }
MaplessBehavior >> initializeOn: aJsonObject with: aMaplessRepository [
	super initialize.
	data := aJsonObject.
	self setSubModelReferencesIn: aMaplessRepository.
	self setSubModelsIn: aMaplessRepository
]

{ #category : #actions }
MaplessBehavior >> insert [
	"Insert this instance into the persistent collection"

	self getRepository insert: self
]

{ #category : #testing }
MaplessBehavior >> isDeleted [
	^ self data includesKey: 'deletedOn'
]

{ #category : #testing }
MaplessBehavior >> isMapless [
	^ true
]

{ #category : #json }
MaplessBehavior >> jsonWriteOn: aStream [
	self maplessData jsonWriteOn: aStream
]

{ #category : #accessing }
MaplessBehavior >> maplessClass [
	^ self class
]

{ #category : #accessing }
MaplessBehavior >> maplessClassName [
	^ self class maplessClassName
]

{ #category : #accessing }
MaplessBehavior >> maplessData [
	"Returns the data part of a Mapless document.
	By default it is the data object, but subclasses might extend or change this."

	^ self basicMaplessData
]

{ #category : #converting }
MaplessBehavior >> maplessId [
	^ self basicMaplessId
]

{ #category : #actions }
MaplessBehavior >> merge: aMapless [
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
MaplessBehavior >> onAfterDelete [
	"At this point, the mapless was deleted.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onAfterDestroy [
	"This mapless was just destroyed at the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onAfterDestroyed [
	"This mapless was saved by the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onAfterInsert [
	"This mapless was inserted.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onAfterRead [
	"This mapless was just read from the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onAfterSave [
	
]

{ #category : #hooks }
MaplessBehavior >> onAfterSaved [
	"This mapless was saved by the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onAfterUpdate [
	"This mapless was updated.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onAfterUpsert [
	"This mapless was either inserted or updated.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onBeforeDelete [
	"This mapless is about to be deleted (intended to be marked as deleted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onBeforeDestroy [
	"This mapless is about to be destroyed (intended to be permanently removed from the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #hooks }
MaplessBehavior >> onBeforeInsert [
	"This mapless is about to be inserted (intended to be added to the repo for the first time).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

]

{ #category : #hooks }
MaplessBehavior >> onBeforeJSON [
	"This model is about to be stringified in JSON.
	All inst var values that are expected to be model objects, need to be instanciated as expected."

	
]

{ #category : #hooks }
MaplessBehavior >> onBeforeSave [
	"This mapless is about to be saved (intended to get its current state persisted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	self modifiedOn: DateAndTime now
]

{ #category : #hooks }
MaplessBehavior >> onBeforeUpdate [
	"This mapless is about to be updated (intended to get its current state persisted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	self modifiedOn: DateAndTime now
]

{ #category : #hooks }
MaplessBehavior >> onBeforeUpsert [
	"This mapless is about to be upserted (intended to be added to the repo either for 
	the first time or updating the stored version).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	
]

{ #category : #actions }
MaplessBehavior >> sanitize: someFields [
	"Removes someFields from the receiver."

	someFields do: [ :key | self data removeKey: key ifAbsent: [ nil ] ]
]

{ #category : #actions }
MaplessBehavior >> save [
	"Storage this instance into the persistent collection"

	self getRepository save: self
]

{ #category : #actions }
MaplessBehavior >> setReferenceFrom: aJsonObject on: aKey of: parentJsonObject in: aMaplessRepository [
	parentJsonObject
		at: aKey
		put: (MaplessReference fromJSONObject: aJsonObject in: aMaplessRepository)
]

{ #category : #actions }
MaplessBehavior >> setReferencesFrom: someJsonObjects on: aKey of: parentJsonObject in: aMaplessRepository [
	parentJsonObject
		at: aKey
		put:
			(someJsonObjects
				collect:
					[ :jsonObject | MaplessReference fromJSONObject: jsonObject in: aMaplessRepository ])
]

{ #category : #actions }
MaplessBehavior >> setSubModelReferencesAt: aKey with: anObject in: aMaplessRepository [
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
MaplessBehavior >> setSubModelReferencesIn: aMaplessRepository [
	"Creates proxies to sub models regarding 
	to the JSON data this instance."

	self maplessData
		keysAndValuesDo:
			[ :k :v | self setSubModelReferencesAt: k with: v in: aMaplessRepository ]
]

{ #category : #actions }
MaplessBehavior >> setSubModelsAt: aKey with: anObject in: aMaplessRepository [
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
MaplessBehavior >> setSubModelsIn: aMaplessRepository [
	"On demand creates sub models regarding 
	to the JSON data this instance."

	self data
		keysAndValuesDo: [ :k :v | self setSubModelsAt: k with: v in: aMaplessRepository ]
]

{ #category : #actions }
MaplessBehavior >> unreferenced [
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
MaplessBehavior >> update [
	self getRepository update: self
]

{ #category : #actions }
MaplessBehavior >> upsert [
	"Storage this instance into the persistent collection"

	self getRepository upsert: self
]
