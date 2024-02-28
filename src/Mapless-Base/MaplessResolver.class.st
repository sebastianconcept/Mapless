"
I'm the abstraction of the resolvers that helps a concrete MaplessRepository know how to resolve classes in the image and collection names.
"
Class {
	#name : #MaplessResolver,
	#superclass : #Object,
	#category : #'Mapless-Base-Resolvers'
}

{ #category : #converting }
MaplessResolver >> asMaplessReferenceIn: anObject in: aMaplessRepository [

	^ MaplessReference for: anObject in: aMaplessRepository
]

{ #category : #testing }
MaplessResolver >> canRepresentArrayOfMaplessReferences: anObject in: aMaplessRepository [
	"Answers true if anObject can represent a collection of sub mapless references."

	^ anObject isCollection
		and: [ anObject
				anySatisfy:
					[ :anyOne | self canRepresentSubMapless: anyOne in: aMaplessRepository ] ]
]

{ #category : #testing }
MaplessResolver >> canRepresentSubMapless: anObject in: aMaplessRepository [
	"Answers true if anObject can represent a sub mapless."

	^ anObject isDictionary
		and: [ anObject size = 2
				and: [ (anObject includesKey: aMaplessRepository idPropertyName ) and: [ anObject includesKey: '_c' ] ] ]
]

{ #category : #accessing }
MaplessResolver >> conditionForClass: aMaplessClass [
	^ {('_c' -> aMaplessClass name)} asDictionary
]

{ #category : #converting }
MaplessResolver >> maplessAsStorable: aMapless in: aMaplessRepository [
	^ aMaplessRepository asStorable: aMapless
]

{ #category : #accessing }
MaplessResolver >> maplessClassFor: aJsonObject in: aMaplessRepository [
	| className |
	className := self
		maplessClassNameFor: aJsonObject
		in: aMaplessRepository.
	^ Smalltalk
		at: className asSymbol
		ifAbsent: [ MaplessClassNotFound
				signal:
					('The {1} class was not found in this image' format: {className}) ]
]

{ #category : #accessing }
MaplessResolver >> maplessClassNameFor: aJsonObject in: aMaplessRepository [
	^ aJsonObject at: '_c'
]

{ #category : #converting }
MaplessResolver >> maplessReferenceAsJsonObject: aMaplessReference in: aMaplessRepository [
	^ OrderedJsonObject new
		at: '_c' put: aMaplessReference maplessClassName;
		at: aMaplessRepository idPropertyName put: aMaplessReference id;
		yourself
]

{ #category : #hooks }
MaplessResolver >> onBeforeSave: aMapless [
	"no-op"
]

{ #category : #accessing }
MaplessResolver >> referenceDataFrom: aJsonObject in: aMaplessRepository [
	^ JsonObject new
		at: aMaplessRepository idPropertyName
			put: (aJsonObject at: aMaplessRepository idPropertyName);
		at: '_c' put: (aJsonObject at: '_c');
		yourself
]

{ #category : #converting }
MaplessResolver >> storableFor: aMapless in: aMaplessRepository [
	"Returns a new JsonObject that's a serializable friendly 
	version of the jsonObject of aMapless.
	It does that by deep visiting and casting all its values. 
	It will complain if sub models are not previously saved."

	| storableDocument storablePart |
	storableDocument := JsonObject new.
	aMapless maplessData
		keysAndValuesDo: [ :key :value | 
			storablePart := aMaplessRepository asStorable: value.
			key ~= 'id'
				ifTrue: [ storableDocument at: key put: storablePart ] ].
	^ storableDocument
]
