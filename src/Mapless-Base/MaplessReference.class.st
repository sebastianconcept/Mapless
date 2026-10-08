"
When a mapless is composed with another mapless it will use a MaplessReference proxy when is read from the database.
"
Class {
	#name : #MaplessReference,
	#superclass : #Object,
	#instVars : [
		'model',
		'data',
		'repository'
	],
	#category : #'Mapless-Base-Models'
}

{ #category : #actions }
MaplessReference class >> for: aMapless in: aMaplessRepository [
	^ self new
		initializeOnMapless: aMapless in: aMaplessRepository;
		yourself
]

{ #category : #actions }
MaplessReference class >> fromJSONObject: aJsonObject in: aMaplessRepository [
	^ self new
		initializeOnData: (aMaplessRepository referenceDataFrom: aJsonObject)
			in: aMaplessRepository;
		yourself
]

{ #category : #actions }
MaplessReference class >> fromJSONString: aJSONString in: aMaplessRepository [
	^ self
		fromJSONObject: (OrderedJson readFrom: aJSONString readStream)
		in: aMaplessRepository
]

{ #category : #accessing }
MaplessReference >> = anObject [
	^ self id notNil
		and: [ self id = anObject id and: [ self maplessClassName = anObject _c ] ]
]

{ #category : #actions }
MaplessReference >> asJsonObjectIn: aMaplessRepository [
	"The only valid scenario when this won't have an id 
	is when it wraps an unsaved submodel"

	"a nil id at this point should never happen"

	self id
		ifNil: [ ^ MaplessUnsavedSubmodel
				signal:
					'This sub model is unsaved. You need to save all sub mapless before saving a composed mapless' ].
	^ aMaplessRepository maplessReferenceAsJsonObject: self
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
	^ repository
		findOne: self maplessClass
		atId: (data at: repository idPropertyName)
]

{ #category : #testing }
MaplessReference >> hasModel [
	^ model notNil
]

{ #category : #accessing }
MaplessReference >> id [
	^ model isNil
		ifFalse: [ model id ]
		ifTrue: [ data at: repository idPropertyName ]
]

{ #category : #initialization }
MaplessReference >> initializeModel [
	"Note this reference will load the model from the database only once,
	usually in the first message send"

	"sas: this should be improved to decouple this guy from the specific strategy needed for model retrieve. Maybe a responsibility of a resolver https://github.com/sebastianconcept/Mapless/issues/22"

	^ model := self getMongoModel
]

{ #category : #initialization }
MaplessReference >> initializeOnData: aJsonObject in: aMaplessRepository [
	data := self withNormalizedId: aJsonObject in: aMaplessRepository.
	repository := aMaplessRepository
]

{ #category : #initialization }
MaplessReference >> initializeOnMapless: aMapless in: aRepository [
	model := aMapless.
	repository := aRepository
]

{ #category : #testing }
MaplessReference >> isKindOf: aClasss [
	^ self model isKindOf: aClasss
]

{ #category : #actions }
MaplessReference >> jsonWriteOn: aStream [
	(self asJsonObjectIn: repository) jsonWriteOn: aStream
]

{ #category : #accessing }
MaplessReference >> maplessClass [
	^ Smalltalk
		at: self maplessClassName asSymbol
		ifAbsent: [ MaplessClassNotFound
				signal:
					('The {1} class was not found in this image'
						format: {self maplessClassName asString}) ]
]

{ #category : #accessing }
MaplessReference >> maplessClassName [
	^ model isNil
		ifFalse: [ model class name ]
		ifTrue: [ data at: '_c' ]
]

{ #category : #accessing }
MaplessReference >> maplessData [
	^ self hasModel
		ifTrue: [ model maplessData ]
		ifFalse: [ data ]
]

{ #category : #accessing }
MaplessReference >> model [
	^ model ifNil: [ self initializeModel ]
]

{ #category : #printing }
MaplessReference >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self maplessClassName;
		nextPut: $)
]

{ #category : #actions }
MaplessReference >> unreferenced [
	^ self model unreferenced
]

{ #category : #initialization }
MaplessReference >> withNormalizedId: aJsonObject in: aMaplessRepository [
	^ aJsonObject
		at: aMaplessRepository idPropertyName
			put:
			(aMaplessRepository
				withNormalizedId: (aJsonObject at: aMaplessRepository idPropertyName));
		yourself
]
