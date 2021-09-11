"
When a mapless is composed with another mapless it will use a MaplessReference proxy when is read from the database.
"
Class {
	#name : #MaplessReference,
	#superclass : #Object,
	#instVars : [
		'maplessClass',
		'id',
		'model'
	],
	#category : #'Mapless-Base-Core-Models'
}

{ #category : #actions }
MaplessReference class >> for: aMapless [
	^ self new
		initializeOn: aMapless;
		yourself
]

{ #category : #actions }
MaplessReference class >> fromJSONObject: aJsonObject [
	^ self new
		id: (aJsonObject at: Mapless idPropertyName);
		maplessClass: aJsonObject _c;
		yourself
]

{ #category : #actions }
MaplessReference class >> fromJSONString: aJSONString [
	^ self fromJSONObject: (OrderedJson readFrom: aJSONString readStream)
]

{ #category : #actions }
MaplessReference class >> fromVoyageReference: aDictionaryish [
	"Answers a MaplessReference based on the voyage reference information found at aDictionaryish.
	It assumes the Mapless model class to create for the corresponding composed object has the same name as Voyage would expect suffixed with 'Mapless'.
	Example: if voyage has this object as BlahUser its document would instantiate BlahUserMapless instances."

	| classSelector |
	classSelector := (aDictionaryish at: '#instanceOf') , 'Mapless'.
	^ self
		fromVoyageReference: aDictionaryish
		classSelector: classSelector
]

{ #category : #actions }
MaplessReference class >> fromVoyageReference: aJsonObject classSelector: classSelector [
	^ self new
		id: (aJsonObject at: '__id');
		maplessClass: classSelector;
		yourself
]

{ #category : #accessing }
MaplessReference >> = anObject [
	^ super = anObject
		or: [ self id = anObject id and: [ self _c = anObject _c ] ]
]

{ #category : #actions }
MaplessReference >> asJsonObject [
	"The only valid scenario when this won't have an id 
	is when it wraps an unsaved submodel"

	id ifNil: [ id := model id ].
	"a nil id at this point should never happen"
	id
		ifNil: [ ^ MaplessUnsavedSubmodel
				signal:
					'This sub model is unsaved. You need to save all sub mapless before saving a composed mapless' ].
	self assert: id notNil.
	^ OrderedJsonObject new
		at: '_c' put: maplessClass;
		at: MaplessCurrentRepository value idPropertyName put: id;
		yourself
]

{ #category : #accessing }
MaplessReference >> doesNotUnderstand: aMessage [
	"The idea behind this DNU is to use the selector as setters or getter 
	delegating to data (aJsonObject)"

	^ self model
		perform: aMessage selector
		withArguments: aMessage arguments
]

{ #category : #accessing }
MaplessReference >> getMongoModel [
	| class |
	class := Smalltalk
		at: maplessClass asSymbol
		ifAbsent: [ self
				error: 'This image does not have ' , maplessClass asString , ' class' ].
	^ class findId: id
]

{ #category : #testing }
MaplessReference >> hasModel [
	^ model notNil
]

{ #category : #accessing }
MaplessReference >> id [
	^ id
]

{ #category : #accessing }
MaplessReference >> id: anObject [
	id := anObject
]

{ #category : #initialization }
MaplessReference >> initializeModel [
	"Note this reference will load the model from the database only once,
	usually in the first message send"

	self flag: #todo.
	"sas: this should be improved to decouple this guy from the specific strategy needed for model retrieve.
	Can a dynamic variable help in deciding what's the strategy to get the model?
	So if you're using Redis go a Redis get, if using Mongo a Mongo get, ditto with Postgres"
	model := self getMongoModel.
	(model notNil and: [ model isUnsaved not ])
		ifTrue: [ id := model id ].
	^ model
]

{ #category : #initialization }
MaplessReference >> initializeOn: aMongoMapless [
	id := aMongoMapless id.
	maplessClass := aMongoMapless class maplessClassName.
	model := aMongoMapless
]

{ #category : #testing }
MaplessReference >> isKindOf: aClasss [
	^ self model isKindOf: aClasss
]

{ #category : #actions }
MaplessReference >> jsonWriteOn: aStream [
	self asJsonObject jsonWriteOn: aStream
]

{ #category : #accessing }
MaplessReference >> maplessClass [
	^ maplessClass
]

{ #category : #accessing }
MaplessReference >> maplessClass: aString [
	maplessClass := aString
]

{ #category : #accessing }
MaplessReference >> model [
	^ model ifNil: [ self initializeModel ]
]

{ #category : #accessing }
MaplessReference >> model: anObject [
	model := anObject
]

{ #category : #actions }
MaplessReference >> unreferenced [
	^ self model unreferenced
]
