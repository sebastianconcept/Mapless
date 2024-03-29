"
I help with using a Voyage backend creating Mapless and MaplessReferences out of data meant for Voyage documents.
"
Class {
	#name : #MaplessVoyageWithMaplessSuffixResolver,
	#superclass : #MaplessResolver,
	#instVars : [
		'suffix'
	],
	#category : #'Mapless-Base-Resolvers'
}

{ #category : #testing }
MaplessVoyageWithMaplessSuffixResolver >> canRepresentSubMapless: anObject in: aMaplessRepository [
	"Answers true if anObject can represent a sub mapless."

	^ (anObject isDictionary
		and: [ (anObject includesKey: '_id') and: [ anObject includesKey: '_c' ] ])
		or: [ self isVoyageReference: anObject in: aMaplessRepository ]
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> conditionForClass: aMaplessClass [
	^ {('#instanceOf' -> (self voyageClassNameFrom: aMaplessClass))}
		asDictionary
]

{ #category : #converting }
MaplessVoyageWithMaplessSuffixResolver >> ensureVoyageMetadataIn: storableDocument for: aMapless in: aMaplessRepository [
	"Makes sure aMapless has the metadata that would be expected by Voyage."

	(aMaplessRepository isUnsaved: aMapless)
		ifFalse: [ storableDocument at: '_id' put: aMapless id ].
	storableDocument
		at: '#instanceOf' put: (self voyageClassNameFrom: aMapless);
		yourself
]

{ #category : #testing }
MaplessVoyageWithMaplessSuffixResolver >> isVoyage: anObject in: aMaplessRepository [
	"Answers true if anObject has the keys and values of a voyage object or reference."

	^ anObject isDictionary
		and: [ (((anObject includesKey: '_id')
				or: [ (anObject includesKey: '__id')
						and: [ anObject includesKey: '#collection' ] ])
				or: [ anObject includesKey: 'id' ])
				and: [ anObject includesKey: '#instanceOf' ] ]
]

{ #category : #testing }
MaplessVoyageWithMaplessSuffixResolver >> isVoyageReference: anObject in: aMaplessRepository [
	"Answers true if anObject has the keys and values of a voyage reference."

	^ anObject isDictionary
		and: [ (anObject includesKey: '__id')
				and: [ (anObject includesKey: '#instanceOf')
						and: [ anObject includesKey: '#collection' ] ] ]
]

{ #category : #converting }
MaplessVoyageWithMaplessSuffixResolver >> maplessAsStorable: anObject in: aMaplessRepository [
	anObject isMapless
		ifTrue: [ anObject maplessData
				at: '_id' put: anObject id;
				at: '#instanceOf' put: anObject class maplessClassName;
				yourself ].
	^ super maplessAsStorable: anObject in: aMaplessRepository
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> maplessClassFor: aJsonObject in: aMaplessRepository [
	| className |
	className := self
		maplessClassNameFor: aJsonObject
		in: aMaplessRepository.
	^ Smalltalk
		at: className asSymbol
		ifAbsent: [ MaplessClassNotFound
				signal:
					('The {1} class was not found in this image'
						format: {self maplessClassName asString}) ]
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> maplessClassNameFor: aJsonObject in: aMaplessRepository [
	^ (self isVoyage: aJsonObject in: aMaplessRepository)
		ifTrue: [ self maplessClassNameFromVoyageReference: aJsonObject ]
		ifFalse: [ aJsonObject at: '_c' ]
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> maplessClassNameFromVoyageReference: aJsonObject [
	^ (aJsonObject at: '#instanceOf') , suffix
]

{ #category : #converting }
MaplessVoyageWithMaplessSuffixResolver >> maplessReferenceAsJsonObject: aMaplessReference in: aMaplessRepository [
	^ (super
		maplessReferenceAsJsonObject: aMaplessReference
		in: aMaplessRepository)
		at: '__id' put: aMaplessReference id;
		at: '#instanceOf' put: (self voyageClassNameFrom: aMaplessReference);
		at: '#collection' put: (self voyageCollectionNameFrom: aMaplessReference);
		yourself
]

{ #category : #converting }
MaplessVoyageWithMaplessSuffixResolver >> noasMaplessReferenceIn: aMapless in: aMaplessRepository [
	| reference |
	reference := super
		asMaplessReferenceIn: aMapless
		in: aMaplessRepository.
	reference data
		at: '__id' put: aMapless id;
		at: '#instanceOf' put: (self voyageClassNameFrom: aMapless);
		at: '#collection' put: (self voyageCollectionNameFrom: aMapless);
		yourself.
	^ reference
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> referenceDataFrom: aJsonObject in: aMaplessRepository [
	^ (aMaplessRepository resolver
		isVoyageReference: aJsonObject
		in: aMaplessRepository)
		ifTrue: [ JsonObject new
				at: aMaplessRepository idPropertyName put: aJsonObject __id;
				at: '_c' put: (self maplessClassNameFromVoyageReference: aJsonObject);
				yourself ]
		ifFalse: [ aJsonObject ]
]

{ #category : #converting }
MaplessVoyageWithMaplessSuffixResolver >> storableFor: aMapless in: aMaplessRepository [
	"Returns a new JsonObject that's the BSON friendly version of the jsonObject of aMapless.
	It does that by visiting to cast all the values. 
	It will complain if sub models are not previously saved."

	| storableDocument |
	storableDocument := super
		storableFor: aMapless
		in: aMaplessRepository.
	self
		ensureVoyageMetadataIn: storableDocument
		for: aMapless
		in: aMaplessRepository.
	^ storableDocument
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> suffix [
	^ suffix
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> suffix: anObject [
	suffix := anObject
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> voyageClassNameFrom: aMaplessOrMaplessReference [
	| className where |
	className := aMaplessOrMaplessReference maplessClassName.
	where := className findString: suffix.
	^ className copyFrom: 1 to: where - 1
]

{ #category : #accessing }
MaplessVoyageWithMaplessSuffixResolver >> voyageCollectionNameFrom: aMapless [
	^ self voyageClassNameFrom: aMapless
]
