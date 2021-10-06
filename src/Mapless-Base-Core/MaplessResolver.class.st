"
I'm the abstraction of the resolvers that helps a concrete MaplessRepository how to resolve classes in the image and collection names.
"
Class {
	#name : #MaplessResolver,
	#superclass : #Object,
	#category : #'Mapless-Base-Core-Resolvers'
}

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
				and: [ (anObject includesKey: '_id') and: [ anObject includesKey: '_c' ] ] ]
]

{ #category : #accessing }
MaplessResolver >> maplessClassFor: aJsonObject in: aMaplessRepository [
	| className |
	className := self
		maplessClassNameFor: aJsonObject
		in: aMaplessRepository.
	^ Smalltalk
		at: className asSymbol
		ifAbsent: [ self
				error: 'The resolver could not find ' , className , ' in this image.' ]
]

{ #category : #accessing }
MaplessResolver >> maplessClassNameFor: aJsonObject in: aMaplessRepository [
	^ aJsonObject at: '_c'
]

{ #category : #accessing }
MaplessResolver >> referenceDataFrom: aJsonObject in: aMaplessRepository [
	^ JsonObject new
		at: aMaplessRepository idPropertyName put: aJsonObject _id;
		at: '_c' put: (aJsonObject at: '_c');
		yourself
]
