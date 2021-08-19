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
		'raw',
		'data'
	],
	#classInstVars : [
		'idAttribute'
	],
	#category : #'Mapless-Models'
}

{ #category : #testing }
Mapless class >> canBeMapless: anObject [
	"Answers true if anObject can be used to instantiate mapless."

	^ anObject isDictionary
		and:
			[ anObject size > 1 and: [ anObject includesKey: 'modelClass' ] ]
]

{ #category : #testing }
Mapless class >> canRepresentArrayOfMaplessReferences: anObject [
	"Answers true if anObject can represent a collection of sub mapless references."

	^ anObject isCollection
		and: [ anObject
				anySatisfy: [ :anyOne | self canRepresentSubMapless: anyOne ] ]
]

{ #category : #testing }
Mapless class >> canRepresentSubMapless: anObject [
	"Answers true if anObject can represent a sub mapless."

	^ anObject isDictionary
		and: [ anObject size = 2
				and: [ (anObject includesKey: '_id')
						and: [ anObject includesKey: 'modelClass' ] ] ]
]

{ #category : #accessing }
Mapless class >> collection [

	^ self currentRepository database collectionAt: self collectionName 
]

{ #category : #accessing }
Mapless class >> collectionName [
	"Answers the collection name that is expected to be used by the concrete repository"
	^ name asString
]

{ #category : #accessing }
Mapless class >> currentRepository [

	^MaplessCurrentRepository value
]

{ #category : #testing }
Mapless class >> existsCid: anId [

	^ ( self findCid: anId ) notNil
]

{ #category : #testing }
Mapless class >> existsId: anId [

	^self currentRepository existsId: anId of: self
]

{ #category : #accessing }
Mapless class >> find: someConditions [ 
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^self currentRepository instancesOf: self where: someConditions 
		
]

{ #category : #accessing }
Mapless class >> find: someConditions limit: toHowManyResults [

	^self currentRepository instancesOf: self where: someConditions limit: toHowManyResults 
		
]

{ #category : #accessing }
Mapless class >> find: someConditions limit: howManyResults offset: startingFromWhichResult [

	^self currentRepository instancesOf: self where: someConditions limit: howManyResults offset: startingFromWhichResult  
		
]

{ #category : #accessing }
Mapless class >> findAll [ 
	"Answer a collection with all receiver instances from the repository."

	^self currentRepository instancesOf: self where: Dictionary new 
]

{ #category : #accessing }
Mapless class >> findAllSortedBy: aSelector [
	"Answers all instances or ans empty set.
	Note: this is only a good idea when you have very few of this objects
	and starts to become a REALLY BAD idea when you have, for instance, more than 1000."

	|answer|


	answer := GRSmallOrderedSet  sortSelector: aSelector equalitySelector: #=.
	self modelClasses do:[:aModelClass|
		aModelClass == Mapless ifFalse:[
			answer addAll: aModelClass findAll]].

	^ answer
]

{ #category : #accessing }
Mapless class >> findCid: anId [

	^self currentRepository 
		instanceOf: self 
		where: (Dictionary newFromPairs: {'cid'. anId})
	
	
]

{ #category : #accessing }
Mapless class >> findId: anId [

	^self currentRepository instanceOf: self atId: anId
]

{ #category : #accessing }
Mapless class >> findOne: someConditions [ 
	"Answer a collection of instances of the receiver that meet with someConditions from the repository."

	^self currentRepository instanceOf: self where: someConditions 
		
]

{ #category : #accessing }
Mapless class >> first [ 

	^self currentRepository instanceOf: self where: Dictionary new
		
]

{ #category : #actions }
Mapless class >> fromBSON: someBSONData [

	^ self fromJSONObject: (BSON read: someBSONData readStream) asJsonObject 
]

{ #category : #actions }
Mapless class >> fromJSON: aJSONString [

	^ self new 
		raw: aJSONString;
		yourself
]

{ #category : #actions }
Mapless class >> fromJSONObject: aJsonObjectOrNilOrArray [

	| modelClass | 
	aJsonObjectOrNilOrArray ifNil: [ ^ nil ].
	aJsonObjectOrNilOrArray isArray ifTrue: [ ^ self fromJSONObjects: aJsonObjectOrNilOrArray ].
	 
	"If the content has metadata then it will use it to decide what instances to create.
	When there is no Mapless metadata available, the assumption is 
	that it should create instances of this class of Mapless."
	modelClass := aJsonObjectOrNilOrArray at: 'modelClass' ifAbsent: [ self name ].
	
	^ (Smalltalk at: modelClass asSymbol) basicNew 
		initializeOn: aJsonObjectOrNilOrArray asJsonObject;
		yourself 

]

{ #category : #actions }
Mapless class >> fromJSONObjects: someJsonObjects [

	^ someJsonObjects collect:[:e|
		self fromJSONObject: e]
]

{ #category : #actions }
Mapless class >> fromJSONString: aJsonString [
	^ self fromJsonObject: (OrderedJson readFrom: aJsonString readStream)
]

{ #category : #actions }
Mapless class >> fromJsonObject: aJsonObjectOrNilOrArray [
	| modelClass |
	aJsonObjectOrNilOrArray ifNil: [ ^ nil ].
	aJsonObjectOrNilOrArray isArray
		ifTrue: [ ^ self fromJSONObjects: aJsonObjectOrNilOrArray ].

	"If the content has metadata then it will use it to decide what instances to create.
	When there is no Mapless metadata available, the assumption is 
	that it should create instances of this class of Mapless."
	modelClass := aJsonObjectOrNilOrArray
		at: 'modelClass'
		ifAbsent: [ self name ].
	^ (Smalltalk at: modelClass asSymbol) basicNew
		initializeOn: aJsonObjectOrNilOrArray asJsonObject;
		yourself
]

{ #category : #accessing }
Mapless class >> fromReified: aJsonObject [ 

	^ self fromJSONObject: aJsonObject 
]

{ #category : #accessing }
Mapless class >> fromResults: someMongoTalkResults [

	^(someMongoTalkResults isNil or: [ someMongoTalkResults isEmpty ] )
		ifTrue: [ #() ]
		ifFalse: [ (self fromJSONObjects: someMongoTalkResults) collect: [ :each | self currentRepository onAfterRead: each ] ]
]

{ #category : #actions }
Mapless class >> getNewId [
	^ OID nextOID
]

{ #category : #accessing }
Mapless class >> idAttribute [
	"Answers the attribute name for the id used by the backend.
	Different persistance backends might use different names.
	For example: '_id'  'id'  'oid'  etc"

	^ self currentRepository idAttribute 
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

{ #category : #testing }
Mapless class >> isVoyageReference: anObject [
	"Answers true if anObject has the keys and values of a voyage reference."

	^ anObject isDictionary
		and: [ anObject size = 3
				and: [ (anObject includesKey: '__id')
						and: [ (anObject includesKey: '#instanceOf')
								and: [ anObject includesKey: '#collection' ] ] ] ]
]

{ #category : #accessing }
Mapless class >> keysToExclude [
	"Answers the names of the keys that should be ignored 
	during some operations (like copying for example)"
	
	^ #(
	'_id'
	'id'
	'v'
	)
]

{ #category : #actions }
Mapless class >> mergeByCidWithStored: aMapless [
	"Merges the stored verision of aMapless (found by cid) by
	 overwriting and adding whatever is in aMapless."
	
	| stored |

	stored := aMapless freshFromCid.
	stored 
		ifNil: [ stored := aMapless ]
		ifNotNil: [ 
			aMapless data keysAndValuesDo: [ :k :v |
				stored data at: k put: v ] ].

	^ stored
]

{ #category : #accessing }
Mapless class >> modelClasses [
	"Answers the set of classes which are concrete model classes.
	Note: deprecated or abstract ones are going to be excluded"

	^ self withAllSubclasses reject: [ :aClass | aClass isAbstract or: [ aClass isDeprecated ] ]
]

{ #category : #accessing }
Mapless class >> pluralName [
	"Answers the string expected in a nicely designed API.
	Any subclass can override its own custom name.
	The default plural name is the singular name 
	in lower case plus an 's' so beware of irregular nouns."
	
	^ self singularName, 's'

]

{ #category : #accessing }
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
	
	^ (aModel class = self class) and:[
	self id = aModel id ]
]

{ #category : #accessing }
Mapless >> asBSON [
	
	^ BSON write: self asBSONFriendly 
]

{ #category : #accessing }
Mapless >> asBSONFriendly [

	^ Dictionary new 
		at: 'key' put: self id;
		at: 'value' put: self asNoSQLValue;
		yourself
]

{ #category : #accessing }
Mapless >> asDictionary [ 
	"Answers this instance as a JSON friendly dictionary"
	
	^ [:dic| | attributes |
		attributes := OrderedJsonObject new.
		dic at: self class name asString put: attributes.
		self data associationsDo:[:assoc|
			assoc value isPersistentModel 
				ifTrue:[ attributes at: assoc key put: assoc value asDictionary ]
				ifFalse:[ attributes at: assoc key put: assoc value] ].
		dic ] value: OrderedJsonObject new
]

{ #category : #accessing }
Mapless >> asJSONString [
	
	self onBeforeJSON.

	^ super asJSONString
]

{ #category : #actions }
Mapless >> asMaplessReference [ 

	^ MaplessReference for: self

]

{ #category : #accessing }
Mapless >> asNoSQLValue [
	"Answers this aggregate as value you will expect to have in a noSQL storage"
	
	self subclassResponsibility 
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

{ #category : #actions }
Mapless >> beDeleted [

	self isDeleted: true
]

{ #category : #actions }
Mapless >> copyFrom: aMapless [
	"Takes the keys and values from aMapless
	and puts them in the local one.
	All key/values except for those to exclude 
	and without removing any local element."
	
	(aMapless data keys asOrderedCollection 
		removeAllFoundIn: self class keysToExclude;
		yourself) do: [ :k |
			self data at: k put: (aMapless at: k) ]
]

{ #category : #accessing }
Mapless >> createdOn [ 

	| selector expects object |

	selector := #createdOn.
	expects := DateAndTime.

	object := self at: selector asString.
	(object isNil or: [
	object isDictionary and: [
	object isEmpty ]]) ifTrue: [^nil].

	(object isKindOf: expects) ifTrue: [ ^ object ].

	^ self at: selector asString put: (self dateAndTimeAt: selector)

]

{ #category : #accessing }
Mapless >> currentRepository [

	^ self class currentRepository
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
	
	value isString ifTrue: [ ^ DateAndTime fromString: value ].
	
	value isDictionary ifTrue: [ ^ DateAndTime fromUnixTime: (value at: '$date') / 1000 ].
	
	^ nil 
]

{ #category : #actions }
Mapless >> delete [
	"Saves this instance as deleted in the persistent collection"
	
	self currentRepository delete: self

]

{ #category : #actions }
Mapless >> destroy [
	"Removes this instance from the persistent collection"

	^self currentRepository destroy: self

]

{ #category : #accessing }
Mapless >> doesNotUnderstand: aMessage [
	"The idea behind this DNU is to use the selector as setters or getter 
	delegating to data (aJsonObject)"
	
	| key |
	
	key := aMessage selector.

	key isUnary ifTrue: [ ^ self data at: key asString ].

	^ (key isKeyword and: [ ( key occurrencesOf: $: ) = 1] )
		ifTrue: [ key := key allButLast asSymbol.
				self data at: key asString put: aMessage arguments first ]
		ifFalse: [ super doesNotUnderstand: aMessage ]
				
	
]

{ #category : #actions }
Mapless >> ensureId [ 
	"Makes sure this mapless has stamped a backend side id."
	
	self hasId ifFalse: [
		self id: self class getNewId ].
]

{ #category : #actions }
Mapless >> fresh [

	^ self isUnsaved 
		ifTrue: [ self ]
		ifFalse: [ self class findId: self id ]
]

{ #category : #actions }
Mapless >> freshFromCid [

	^ self class findCid: self cid 
]

{ #category : #testing }
Mapless >> hasCid [

	^ self cid notNil
]

{ #category : #testing }
Mapless >> hasId [

	^ self id notNil
]

{ #category : #accessing }
Mapless >> id [
	"Answers the server-side assigned id of this mapless.
	Note: the expectation is to have this id set when is saved/inserted 
	for the first time into a repo. A second important expectation is that
	different repositories might use different names to store their 'id'
	for example MongoDB uses '_id' and Postgres uses 'oid' and others
	might use variations that should get normalized into 'id'."
	
	^ self data at: 'id'
]

{ #category : #accessing }
Mapless >> id: anId [

	^ self data 
		at: 'id'
		put: anId
]

{ #category : #initialization }
Mapless >> initialize [

	super initialize.
		
	"We include the class name so we have the minimal metadata at consuming time"
	self modelClass: self class name.
	self createdOn: DateAndTime now.

]

{ #category : #accessing }
Mapless >> initializeData [

	^ raw 
		ifNil: [ data := OrderedJsonObject new ]
		ifNotNil: [ data := Json readFrom: raw readStream ]
]

{ #category : #initialization }
Mapless >> initializeOn: aJsonObject [
	super initialize.
	data := aJsonObject.

	"We include the class name so we have the minimal metadata at consuming time"
	self modelClass ifNil: [ self modelClass: self class name ].
	self createdOn ifNil: [ self createdOn: DateAndTime now ].
	self setSubModelReferences.
	self setSubModels
]

{ #category : #actions }
Mapless >> insert [
	"Insert this instance into the persistent collection"

	^self currentRepository insert: self
]

{ #category : #testing }
Mapless >> isDeleted [

	| isDeleted |
	
	isDeleted  := self data at: 'isDeleted'.
	^ isDeleted notNil and: [ isDeleted ]
]

{ #category : #testing }
Mapless >> isPersistentModel [

	^ true
]

{ #category : #testing }
Mapless >> isReifiedJSON: anObject [ 

	^ (anObject isKindOf: JsonObject) or: [
	anObject isKindOf: OrderedJsonObject ] 
]

{ #category : #testing }
Mapless >> isUnsaved [
	"Answer true if this instance was not saved yet"

	^ self currentRepository isUnsaved: self
]

{ #category : #actions }
Mapless >> jsonWriteOn: aStream [

	self data jsonWriteOn: aStream
]

{ #category : #actions }
Mapless >> makeReferenceFrom: aJSONString [
	"Answers a new reference from aJSONString (or nil if doesn't feel like one)"

	| jsonObject |
	self flag: #deprecated.
	"Will be removed, use:
	MaplessReference fromJSONObject: aJsonObject"
	jsonObject := [ Json readFrom: aJSONString readStream ]
		ifError: [ :x | nil ].
	^ (jsonObject notNil
		and: [ (jsonObject at: self class idAttribute) notNil
				and: [ jsonObject modelClass notNil ] ])
		ifTrue: [ MaplessReference fromJSONObject: jsonObject ]
		ifFalse: [ nil ]
]

{ #category : #actions }
Mapless >> merge: aMapless [
	"Merge the contents of this mapless instance with the contents in aMapless.
	It will NOT resolve merge conflicts or anything smart.
	It's just adding the missing parts.
	It does it deep, though."
	
	(aMapless data keys asOrderedCollection 
		removeAllFoundIn: aMapless class keysToExclude;
		yourself) do: [ :aKey | | part |
			part := aMapless perform: aKey asSymbol.
			(part isKindOf: Mapless) ifTrue: [ |subMaplessOrNil|
				subMaplessOrNil := self perform: aKey asSymbol.
				subMaplessOrNil ifNotNil: [ subMaplessOrNil merge: part ] ].
			self data at: aKey ifAbsentPut: [ part ] ]
]

{ #category : #reactions }
Mapless >> onAfterDelete [
	"At this point, the mapless was deleted.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
]

{ #category : #reactions }
Mapless >> onAfterDestroy [
	"This mapless was just destroyed at the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
]

{ #category : #reactions }
Mapless >> onAfterDestroyed [
	"This mapless was saved by the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
]

{ #category : #reactions }
Mapless >> onAfterRead [
	"This mapless was just read from the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
]

{ #category : #reactions }
Mapless >> onAfterSaved [
	"This mapless was saved by the backend.
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
]

{ #category : #reactions }
Mapless >> onBeforeDelete [
	"This mapless is about to be deleted (intended to be marked as deleted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
]

{ #category : #reactions }
Mapless >> onBeforeDestroy [
	"This mapless is about to be destroyed (intended to be permanently removed from the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
]

{ #category : #reactions }
Mapless >> onBeforeInsert [
	"This mapless is about to be inserted (intended to be added to the repo for the first time).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
	
	self ensureId
]

{ #category : #reactions }
Mapless >> onBeforeJSON [
	"This model is about to be stringified in JSON.
	All inst var values that are expected to be model objects, need to be instanciated as expected."

	
]

{ #category : #reactions }
Mapless >> onBeforeSave [
	"This mapless is about to be saved (intended to get its current state persisted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."

	self modifiedOn: DateAndTime now
]

{ #category : #reactions }
Mapless >> onBeforeUpdate [
	"This mapless is about to be updated (intended to get its current state persisted in the repo).
	This is a convenience message sent by the backend 
	for subclasses to take any (re)action of this interesting moment."
	
	self modifiedOn: DateAndTime now
]

{ #category : #accessing }
Mapless >> persistenceStrategy [

	^ self class currentRepository
]

{ #category : #accessing }
Mapless >> raw [

	^ raw
]

{ #category : #accessing }
Mapless >> raw: aJSONString [

	raw := aJSONString 
	
]

{ #category : #actions }
Mapless >> sanitize: someFields [ 	
	"Removes someFields from the receiver."
	
	someFields do: [ :key |
		self data removeKey: key ifAbsent: [ nil ] ]
]

{ #category : #actions }
Mapless >> save [
	"Storage this instance into the persistent collection"

	^self currentRepository save: self
]

{ #category : #actions }
Mapless >> setModelFrom: aJsonString on: aKey of: aJsonObject [
	"Set model (only if someJsonStrings feels like those)"

	| json modelClass newSubModel |

	json := Json readFrom: aJsonString readStream.	
	modelClass := Smalltalk 
						at: (json at: 'modelClass') asSymbol
						ifAbsent:[self error: 'Cannot find that class'].
							
	newSubModel :=  modelClass fromJSONObject: json.

	newSubModel setSubModels.
	
	 aJsonObject 
		at: aKey 
		put: newSubModel 
]

{ #category : #actions }
Mapless >> setModelsFrom: someJsonStrings on: aKey of: aJsonObject [
	"Set models (only if someJsonStrings feels like those)"

	| modelClass newSubModel |

	 aJsonObject 
		at: aKey 
		put: (someJsonStrings collect: [:json| 
				modelClass := Smalltalk 
								at: (json at: 'modelClass') asSymbol
								ifAbsent: [ self error: 'Cannot find that class' ].
				newSubModel := modelClass fromJSON: json.
				newSubModel setSubModels.
				newSubModel])
]

{ #category : #actions }
Mapless >> setReferenceFrom: aJsonObject on: aKey of: parentJsonObject [
	parentJsonObject
		at: aKey
		put: (MaplessReference fromJSONObject: aJsonObject)
]

{ #category : #actions }
Mapless >> setReferencesFrom: someJsonObjects on: aKey of: parentJsonObject [
	parentJsonObject
		at: aKey
		put:
			(someJsonObjects
				collect: [ :jsonObject | MaplessReference fromJSONObject: jsonObject ])
]

{ #category : #actions }
Mapless >> setSubModelReferences [
	"Creates proxies to sub models regarding 
	to the JSON data this instance."

	self data keysAndValuesDo: [ :k :v |
		self setSubModelReferencesAt: k with: v ]
]

{ #category : #actions }
Mapless >> setSubModelReferencesAt: aKey with: anObject [
	"1. It's a submodel"

	(self class canRepresentSubMapless: anObject)
		ifTrue: [ ^ self setReferenceFrom: anObject on: aKey of: self data ].

	"2. it's a collection of submodels"
	(anObject isCollection
		and: [ anObject notEmpty
				and: [ anObject anySatisfy: [ :e | self class canRepresentSubMapless: e ] ] ])
		ifTrue: [ self setReferencesFrom: anObject on: aKey of: self data ]
]

{ #category : #actions }
Mapless >> setSubModels [
	"On demand creates sub models regarding 
	to the JSON data this instance."

	self data keysAndValuesDo: [ :k :v |
		self setSubModelsAt: k with: v ]
]

{ #category : #actions }
Mapless >> setSubModelsAndReferences [
	self setSubModelReferences
]

{ #category : #actions }
Mapless >> setSubModelsAt: aKey with: anObject [
	| modelClass newSubMapless |
	"one submapless"
	(self class canBeMapless: anObject)
		ifTrue: [ modelClass := Smalltalk
				at: (anObject at: 'modelClass') asSymbol
				ifAbsent: [ self error: 'Could not find that class' ].
			newSubMapless := modelClass fromJSONObject: anObject.
			newSubMapless setSubModels.
			self data at: aKey put: newSubMapless ].

	"many submapless"
	(anObject isCollection
		and: [ anObject anySatisfy: [ :e | self class canBeMapless: e ] ])
		ifTrue: [ | subMapless |
			subMapless := anObject
				collect: [ :each | 
					modelClass := Smalltalk
						at: (each at: 'modelClass') asSymbol
						ifAbsent: [ self error: 'Could not find that class' ].
					newSubMapless := modelClass fromJSONObject: each.
					newSubMapless setSubModels ].
			self data at: aKey put: subMapless ]
]

{ #category : #accessing }
Mapless >> subModelAt: aSelector [
	"Answers the reified submodel (instantiating if necessary)."
	
	| subModelData class |

	subModelData := self data at: aSelector.
	subModelData ifNil:[^nil].

	"legacy code from Amber's json serialization
	subModelData := subModelData at: '@data'.
	subModelData ifNil:[^ FlowModelDataError signal: 'Cannot find ', aSelector,'''s data']."
	
	class := subModelData at: 'class'.
	class := Smalltalk at: class asSymbol ifAbsent:[
		MaplessModelMetadataError signal: 'Cannot find ',aSelector,'''s metadata'].
	
	^ class fromReified: subModelData	
]

{ #category : #actions }
Mapless >> unreferenced [ 
	"Returns this model without references to submodels.
	It will reify any proxy (reference to another sub model) found"
	
	self data keysAndValuesDo: [ :k :v |
	
		v class = MaplessReference ifTrue:[ |subModel|
			subModel := v model.
			self data at: k put: subModel unreferenced. ].
		"decend one level into arrays which could hold MaplessMongoReference's"
		v isArray ifTrue: [ | unreferencedCollection |
			unreferencedCollection := OrderedCollection new.
			v do: [:each |
				each class = MaplessReference 
					ifFalse:[unreferencedCollection add: each unreferenced]
					ifTrue: [| subModelInArray |
						subModelInArray := each model.
						unreferencedCollection add: subModelInArray unreferenced] 
				].
			self data at: k put: unreferencedCollection.
			]
		]
]

{ #category : #actions }
Mapless >> update [

	^self currentRepository update: self
	

]
